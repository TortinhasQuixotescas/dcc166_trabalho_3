import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def detect_encoding(file_path):
    """Try common encodings for Portuguese data"""
    encodings = ['iso-8859-1', 'latin1', 'cp1252', 'utf-8']
    for encoding in encodings:
        try:
            with open(file_path, 'r', encoding=encoding) as f:
                f.read(1024)
                return encoding
        except UnicodeDecodeError:
            continue
    return 'iso-8859-1'  # default fallback

def clean_text(text_value):
    """Convert text to lowercase and strip whitespace"""
    if pd.isna(text_value):
        return None
    return str(text_value).strip().lower()

def import_institutions_and_courses(csv_path):
    # Detect file encoding
    encoding = detect_encoding(csv_path)
    print(f"Detected encoding: {encoding}")

    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read CSV file with proper encoding
    try:
        df = pd.read_csv(
            csv_path,
            sep=';',
            encoding=encoding,
            dtype={'CODIGO_EMEC_IES_BOLSA': str}  # Ensure e_mec_code is string
        )
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        return

    # Clean data - remove any rows with missing institution codes or names
    df = df.dropna(subset=['CODIGO_EMEC_IES_BOLSA', 'NOME_IES_BOLSA', 'NOME_CURSO_BOLSA'])
    
    # Get unique institution-course combinations
    institutions = df[['CODIGO_EMEC_IES_BOLSA', 'NOME_IES_BOLSA']].drop_duplicates()
    courses = df[['CODIGO_EMEC_IES_BOLSA', 'NOME_CURSO_BOLSA']].drop_duplicates()
    
    # Process institutions and courses
    with engine.connect() as connection:
        trans = connection.begin()
        try:
            # Track inserted institutions
            institution_ids = {}
            inserted_institutions = 0
            existing_institutions = 0
            
            # Insert institutions
            for _, row in institutions.iterrows():
                e_mec_code = str(row['CODIGO_EMEC_IES_BOLSA']).strip()
                name = clean_text(row['NOME_IES_BOLSA'])
                
                # Check if institution exists
                result = connection.execute(
                    text("SELECT id FROM prouni.institution WHERE e_mec_code = :e_mec_code"),
                    {'e_mec_code': e_mec_code}
                )
                existing = result.scalar()
                
                if not existing:
                    # Insert new institution
                    result = connection.execute(
                        text("""
                            INSERT INTO prouni.institution (name, e_mec_code)
                            VALUES (LOWER(UNACCENT(:name)), :e_mec_code)
                            RETURNING id
                        """),
                        {'name': name, 'e_mec_code': e_mec_code}
                    )
                    institution_id = result.scalar()
                    institution_ids[e_mec_code] = institution_id
                    inserted_institutions += 1
                else:
                    institution_ids[e_mec_code] = existing
                    existing_institutions += 1
            
            # Insert courses
            inserted_courses = 0
            existing_courses = 0
            for _, row in courses.iterrows():
                e_mec_code = str(row['CODIGO_EMEC_IES_BOLSA']).strip()
                course_name = clean_text(row['NOME_CURSO_BOLSA'])
                institution_id = institution_ids.get(e_mec_code)
                
                if not institution_id:
                    continue
                
                # Check if course exists
                result = connection.execute(
                    text("""
                        SELECT id FROM prouni.course 
                        WHERE institution_id = :institution_id AND name = LOWER(UNACCENT(:name))
                    """),
                    {'institution_id': institution_id, 'name': course_name}
                )
                existing = result.scalar()
                
                if not existing:
                    # Insert new course
                    connection.execute(
                        text("""
                            INSERT INTO prouni.course (institution_id, name)
                            VALUES (:institution_id, LOWER(UNACCENT(:name)))
                        """),
                        {'institution_id': institution_id, 'name': course_name}
                    )
                    inserted_courses += 1
                else:
                    existing_courses += 1
            
            trans.commit()
            print(f"\nImport completed successfully:")
            print(f"- Inserted {inserted_institutions} new institutions")
            print(f"- Found {existing_institutions} existing institutions")
            print(f"- Inserted {inserted_courses} new courses")
            print(f"- Skipped {existing_courses} existing courses")
            
        except Exception as e:
            trans.rollback()
            print(f"\nError during import: {e}")
            raise


if __name__ == "__main__":
    csv_file_path = "../../../sources/prouni/2010.csv"
    if not os.path.exists(csv_file_path):
        print(f"Error: File not found at {csv_file_path}")
    else:
        import_institutions_and_courses(csv_file_path)
    csv_file_path = "../../../sources/prouni/2020.csv"
    if not os.path.exists(csv_file_path):
        print(f"Error: File not found at {csv_file_path}")
    else:
        import_institutions_and_courses(csv_file_path)
