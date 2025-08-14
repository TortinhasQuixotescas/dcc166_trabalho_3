import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from datetime import datetime
from collections import Counter  # Added this import

# Load environment variables
load_dotenv()

def clean_text(text_value):
    """Standardize text to lowercase and remove extra whitespace"""
    if pd.isna(text_value):
        return None
    return str(text_value).strip().lower()

def parse_date(date_str):
    """Parse Brazilian date formats (DD-MM-YYYY or DD/MM/YYYY) to Date object"""
    if pd.isna(date_str):
        return None
    
    date_str = str(date_str).strip()
    for fmt in ('%d-%m-%Y', '%d/%m/%Y'):
        try:
            return datetime.strptime(date_str, fmt).date()
        except ValueError:
            continue
    print(f"Warning: Could not parse date '{date_str}'")
    return None

def map_color(color_str):
    """Map Portuguese color names to database ENUM values"""
    color_mapping = {
        'branca': 'BRANCA',
        'preta': 'PRETA',
        'parda': 'PARDA',
        'amarela': 'AMARELA',
        'indigena': 'INDIGENA',
        'indígena': 'INDIGENA',
        'não informada': 'NAO_INFORMADA',
        'nao informada': 'NAO_INFORMADA'
    }
    return color_mapping.get(clean_text(color_str), 'NAO_INFORMADA')

def import_concessions(csv_path):
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read CSV file with ISO-8859-1 encoding (common for Brazilian data)
    try:
        df = pd.read_csv(
            csv_path,
            sep=';',
            encoding='iso-8859-1',
            # nrows=1000,
            dtype={
                'CODIGO_EMEC_IES_BOLSA': str,
                'CPF_BENEFICIARIO_BOLSA': str
            }
        )
    except Exception as e:
        print(f"Failed to read CSV file: {e}")
        return

    # Define column mapping for the fixed format
    COLUMN_MAP = {
        'year': 'ANO_CONCESSAO_BOLSA',
        'e_mec_code': 'CODIGO_EMEC_IES_BOLSA',
        'course_name': 'NOME_CURSO_BOLSA',
        'city_name': 'MUNICIPIO_BENEFICIARIO_BOLSA',
        'uf': 'SIGLA_UF_BENEFICIARIO_BOLSA',
        'color': 'RACA_BENEFICIARIO_BOLSA',
        'birth_date': 'DT_NASCIMENTO_BENEFICIARIO'
    }

    # Clean and transform data
    df_clean = pd.DataFrame()
    for target, source in COLUMN_MAP.items():
        if source in df.columns:
            df_clean[target] = df[source]
    
    df_clean['year'] = df_clean['year'].astype(int)
    df_clean['e_mec_code'] = df_clean['e_mec_code'].str.strip()
    df_clean['course_name'] = df_clean['course_name'].apply(clean_text)
    df_clean['city_name'] = df_clean['city_name'].apply(clean_text)
    df_clean['uf'] = df_clean['uf'].str.upper().str.strip()
    df_clean['color'] = df_clean['color'].apply(map_color)
    df_clean['birth_date'] = df_clean['birth_date'].apply(parse_date)

    # Remove rows with missing essential data
    df_clean = df_clean.dropna(subset=['year', 'e_mec_code', 'course_name', 'city_name', 'uf', 'color', 'birth_date'])

    # Process concessions in batches
    BATCH_SIZE = 1000
    total_rows = len(df_clean)
    print(f"\nStarting import of {total_rows} potential concessions")

    with engine.connect() as conn:
        trans = conn.begin()
        try:
            inserted = 0
            skipped = 0
            missing_courses = []
            missing_cities = []
            
            for i in range(0, total_rows, BATCH_SIZE):
                batch = df_clean.iloc[i:i+BATCH_SIZE]
                batch_inserts = []
                
                for _, row in batch.iterrows():
                    # Check course reference
                    course_query = """
                        SELECT c.id 
                        FROM prouni.course c
                        JOIN prouni.institution i ON c.institution_id = i.id
                        WHERE i.e_mec_code = :e_mec AND LOWER(UNACCENT(c.name)) = LOWER(UNACCENT(:course_name))
                    """
                    course_result = conn.execute(
                        text(course_query),
                        {'e_mec': row['e_mec_code'], 'course_name': row['course_name']}
                    ).scalar()
                    
                    # Check city reference
                    city_query = """
                        SELECT id 
                        FROM census.city 
                        WHERE unaccent(LOWER(name)) = unaccent(LOWER(:city_name))
                        AND federative_unit = :uf
                    """
                    city_result = conn.execute(
                        text(city_query),
                        {'city_name': row['city_name'], 'uf': row['uf']}
                    ).scalar()
                    
                    if course_result and city_result:
                        batch_inserts.append({
                            'course_id': course_result,
                            'city_id': city_result,
                            'year': row['year'],
                            'color': row['color'],
                            'birth_date': row['birth_date']
                        })
                    else:
                        skipped += 1
                        if not course_result:
                            missing_courses.append((row['e_mec_code'], row['course_name']))
                        if not city_result:
                            missing_cities.append((row['city_name'], row['uf']))
                
                # Bulk insert valid concessions
                if batch_inserts:
                    conn.execute(
                        text("""
                            INSERT INTO prouni.concession (
                                course_id, city_id, year, color, birth_date
                            )
                            VALUES (
                                :course_id, :city_id, :year, :color, :birth_date
                            )
                            ON CONFLICT DO NOTHING
                        """),
                        batch_inserts
                    )
                    inserted += len(batch_inserts)
                
                print(f"Processed {min(i+BATCH_SIZE, total_rows)}/{total_rows} records", end='\r')
            
            trans.commit()
            
            # Print detailed missing references report
            if missing_courses or missing_cities:
                print("\n\n=== MISSING REFERENCES REPORT ===")
                
                if missing_courses:
                    print("\nMissing course references (count: institution_code, course_name):")
                    course_counter = Counter(missing_courses)
                    for (e_mec, course), count in course_counter.most_common(10):
                        print(f"- {count:4} x | Institution: {e_mec}, Course: {course}")
                
                if missing_cities:
                    print("\nMissing city references (count: city_name, UF):")
                    city_counter = Counter(missing_cities)
                    for (city, uf), count in city_counter.most_common(10):
                        print(f"- {count:4} x | City: {city}, UF: {uf}")
            
            print(f"\n\nImport completed:")
            print(f"- Successfully inserted {inserted} concessions")
            print(f"- Skipped {skipped} records (missing references)")
            
        except Exception as e:
            trans.rollback()
            print(f"\nError during import: {e}")
            raise

if __name__ == "__main__":
    csv_file_path = "../../../sources/prouni/2010.csv"
    if not os.path.exists(csv_file_path):
        print(f"Error: File not found at {csv_file_path}")
    else:
        import_concessions(csv_file_path)
