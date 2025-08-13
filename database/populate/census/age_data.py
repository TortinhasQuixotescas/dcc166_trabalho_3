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

def import_young_population_data(ods_path):
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
    )
    
    # Read ODS file - skip first 7 header rows
    df = pd.read_excel(
        ods_path,
        sheet_name=0,
        skiprows=7,
        header=None
    )
    
    # Verify we have enough columns (we need 18 columns total)
    if df.shape[1] < 18:
        raise ValueError(f"Expected at least 18 columns, got {df.shape[1]}")

    # Select and rename relevant columns (columns 1-18, skipping the 'level' column for naming)
    population_data = df.iloc[:, 1:19]  # Select columns 1 through 18 (Python is 0-indexed)
    population_data.columns = [
        'ibge_code', 'city_name',
        'total_2010', 'age18_2010', 'age19_2010', 'age20_2010', 'age21_2010', 
        'age22_2010', 'age23_2010', 'age24_2010',
        'total_2022', 'age18_2022', 'age19_2022', 'age20_2022', 'age21_2022',
        'age22_2022', 'age23_2022', 'age24_2022'
    ]
    
    # Clean data - remove any rows with missing IBGE codes
    population_data = population_data.dropna(subset=['ibge_code'])
    
    # Process each city's data
    with engine.connect() as connection:
        trans = connection.begin()
        try:
            for _, row in population_data.iterrows():
                ibge_code = str(int(float(row['ibge_code']))).zfill(7)  # Ensure 7-digit code
                
                # Calculate young population (ages 18-24) for 2010
                young_2010 = sum([
                    clean_population_value(row['age18_2010']),
                    clean_population_value(row['age19_2010']),
                    clean_population_value(row['age20_2010']),
                    clean_population_value(row['age21_2010']),
                    clean_population_value(row['age22_2010']),
                    clean_population_value(row['age23_2010']),
                    clean_population_value(row['age24_2010'])
                ])
                
                # Calculate young population (ages 18-24) for 2022
                young_2022 = sum([
                    clean_population_value(row['age18_2022']),
                    clean_population_value(row['age19_2022']),
                    clean_population_value(row['age20_2022']),
                    clean_population_value(row['age21_2022']),
                    clean_population_value(row['age22_2022']),
                    clean_population_value(row['age23_2022']),
                    clean_population_value(row['age24_2022'])
                ])
                
                # Update 2010 census data
                update_census(connection, ibge_code, 2010, young_2010)
                
                # Update 2022 census data
                update_census(connection, ibge_code, 2022, young_2022)
            
            trans.commit()
            print(f"Successfully updated young population data for {len(population_data)} cities")
        except Exception as e:
            trans.rollback()
            print(f"Error updating data: {e}")
            raise

def update_census(connection, ibge_code, year, young_population):
    # Get the city_id from the ibge_code
    result = connection.execute(
        text("SELECT id FROM census.city WHERE ibge_code = :ibge_code"),
        {'ibge_code': ibge_code}
    )
    city_id = result.scalar()
    
    if not city_id:
        print(f"Skipping city with IBGE code {ibge_code} (not found in database)")
        return
    
    # Update census data with young population
    connection.execute(
        text("""
            UPDATE census.census 
            SET young_population = :young_population
            WHERE city_id = :city_id AND year = :year
        """),
        {
            'city_id': city_id,
            'year': year,
            'young_population': young_population
        }
    )

if __name__ == "__main__":
    ods_file_path = "../../../sources/idade/todos.ods"  # Update with your actual file path
    import_young_population_data(ods_file_path)
