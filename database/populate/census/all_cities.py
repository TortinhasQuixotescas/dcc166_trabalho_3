import os
import pandas as pd
from sqlalchemy import create_engine, exc, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def clean_city_name(full_name):
    """Remove (UF) suffix from city names"""
    return full_name.split('(')[0].strip()

def extract_uf(full_name):
    """Extract UF from parentheses at end of string"""
    return full_name[-3:-1].upper()

def import_all_cities(ods_path):
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read ODS file - skip first 5 rows (header)
    df = pd.read_excel(
        ods_path,
        sheet_name=0,
        skiprows=5,
        header=None
    )
    
    # Select and rename columns
    cities = df.iloc[:, [1, 2]]  # Columns B (ibge_code) and C (full_name)
    cities.columns = ['ibge_code', 'full_name']
    
    # Clean data
    cities = cities.dropna()
    cities['name'] = cities['full_name'].apply(clean_city_name)
    cities['federative_unit'] = cities['full_name'].apply(extract_uf)
    cities['is_metropolitan'] = False
    
    # Prepare final data
    final_data = cities[['ibge_code', 'name', 'federative_unit', 'is_metropolitan']]
    
    # Insert cities with proper transaction handling
    inserted_count = 0
    with engine.connect() as connection:
        trans = connection.begin()
        try:
            for _, row in final_data.iterrows():
                try:
                    # Correct parameter passing using text() and dictionary
                    connection.execute(
                        text("""
                            INSERT INTO census.city (ibge_code, name, federative_unit, is_metropolitan)
                            VALUES (:ibge_code, :name, :federative_unit, :is_metropolitan)
                            ON CONFLICT (ibge_code) DO NOTHING
                        """),
                        {
                            'ibge_code': row['ibge_code'],
                            'name': row['name'],
                            'federative_unit': row['federative_unit'],
                            'is_metropolitan': row['is_metropolitan']
                        }
                    )
                    inserted_count += 1
                except exc.IntegrityError:
                    continue
            trans.commit()
        except Exception as e:
            trans.rollback()
            raise
    
    print(f"Successfully imported {inserted_count} cities.")

if __name__ == "__main__":
    ods_file_path = "../../../sources/cor/todos.ods"  # Update with your actual file path
    import_all_cities(ods_file_path)
