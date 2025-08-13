import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def clean_population_value(value):
    """Convert '-' to 0 and handle other numeric values"""
    if pd.isna(value) or value == '-':
        return 0
    try:
        return int(float(value))
    except (ValueError, TypeError):
        return 0

def import_population_data(ods_path):
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read ODS file - skip first 5 header rows
    df = pd.read_excel(
        ods_path,
        sheet_name=0,
        skiprows=5,
        header=None
    )
    
    # Verify we have enough columns
    if df.shape[1] < 14:
        raise ValueError(f"Expected at least 14 columns, got {df.shape[1]}")

    # Select and rename relevant columns
    population_data = df.iloc[:, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]]
    population_data.columns = [
        'ibge_code', 'city_name',
        'total_2010', 'white_2010', 'black_2010', 'yellow_2010', 'parda_2010', 'indigenous_2010',
        'total_2022', 'white_2022', 'black_2022', 'yellow_2022', 'parda_2022', 'indigenous_2022'
    ]
    
    # Clean data - remove any rows with missing IBGE codes
    population_data = population_data.dropna(subset=['ibge_code'])
    
    # Process each city's data
    with engine.connect() as connection:
        trans = connection.begin()
        try:
            for _, row in population_data.iterrows():
                ibge_code = str(int(float(row['ibge_code']))).zfill(7)  # Ensure 7-digit code
                
                # Insert 2010 census data
                insert_census(connection, ibge_code, 2010, {
                    'total': clean_population_value(row['total_2010']),
                    'white': clean_population_value(row['white_2010']),
                    'black': clean_population_value(row['black_2010']),
                    'yellow': clean_population_value(row['yellow_2010']),
                    'parda': clean_population_value(row['parda_2010']),
                    'indigenous': clean_population_value(row['indigenous_2010'])
                })
                
                # Insert 2022 census data
                insert_census(connection, ibge_code, 2022, {
                    'total': clean_population_value(row['total_2022']),
                    'white': clean_population_value(row['white_2022']),
                    'black': clean_population_value(row['black_2022']),
                    'yellow': clean_population_value(row['yellow_2022']),
                    'parda': clean_population_value(row['parda_2022']),
                    'indigenous': clean_population_value(row['indigenous_2022'])
                })
            
            trans.commit()
            print(f"Successfully imported population data for {len(population_data)} cities")
        except Exception as e:
            trans.rollback()
            print(f"Error importing data: {e}")
            raise

def insert_census(connection, ibge_code, year, data):
    # Get the city_id from the ibge_code
    result = connection.execute(
        text("SELECT id FROM census.city WHERE ibge_code = :ibge_code"),
        {'ibge_code': ibge_code}
    )
    city_id = result.scalar()
    
    if not city_id:
        print(f"Skipping city with IBGE code {ibge_code} (not found in database)")
        return
    
    # Insert or update census data
    connection.execute(
        text("""
            INSERT INTO census.census (
                city_id, year,
                total_population, white_population, black_population,
                yellow_population, parda_population, indigenous_population
            )
            VALUES (
                :city_id, :year,
                :total, :white, :black,
                :yellow, :parda, :indigenous
            )
            ON CONFLICT (city_id, year) DO UPDATE SET
                total_population = EXCLUDED.total_population,
                white_population = EXCLUDED.white_population,
                black_population = EXCLUDED.black_population,
                yellow_population = EXCLUDED.yellow_population,
                parda_population = EXCLUDED.parda_population,
                indigenous_population = EXCLUDED.indigenous_population
        """),
        {
            'city_id': city_id,
            'year': year,
            **data
        }
    )

if __name__ == "__main__":
    ods_file_path = "../../../sources/cor/todos.ods"  # Update with your actual file path
    import_population_data(ods_file_path)
