import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def clean_city_name(full_name):
    """Remove (UF) suffix from city names"""
    return full_name.split('(')[0].strip()

def extract_uf(full_name):
    """Extract UF from parentheses at end of string"""
    return full_name[-3:-1].upper()

def import_metropolitan_cities(ods_path):
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read ODS file - adjust skiprows if needed
    df = pd.read_excel(
        ods_path,
        sheet_name=0,
        skiprows=5,  # Skip header rows
        header=None  # Don't use first row as header
    )
    
    # Manually select and name columns
    cities = df.iloc[:, [1, 2]]  # Select columns B (ibge_code) and C (full_name)
    cities.columns = ['ibge_code', 'full_name']  # Rename columns
    
    # Clean data
    cities = cities.dropna()
    cities['name'] = cities['full_name'].apply(clean_city_name)
    cities['federative_unit'] = cities['full_name'].apply(extract_uf)
    cities['is_metropolitan'] = True
    
    # Prepare final data
    final_data = cities[['ibge_code', 'name', 'federative_unit', 'is_metropolitan']]
    
    # Insert into database
    final_data.to_sql(
        'city',
        engine,
        schema='census',
        if_exists='append',
        index=False,
        method='multi'
    )
    
    print(f"Successfully imported {len(final_data)} metropolitan cities")

if __name__ == "__main__":
    ods_file_path = "../../sources/cor/metropolitanos.ods"  # Update with your actual file path
    import_metropolitan_cities(ods_file_path)
