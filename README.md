# DCC166 Trabalho 3 - ProUni

## Database

### Create

To create the database, use `psql` to connect to your PostgreSQL server.
Replace `<hostname>` and `<username>` with your PostgreSQL server's hostname and your username, respectively.

```bash
psql -h <hostname> -U <username> 
```

Then, execute the following SQL commands.

```postgresql
SET ROLE administrator;
SELECT create_application_roles('prouni');
CREATE DATABASE prouni_prouni;
RESET ROLE;
\c prouni_prouni;
SELECT configure_database_privileges('prouni');
SET ROLE administrator;
CREATE DATABASE prouni_preset;
SELECT assign_application_role_to_user('prouni', 'viewer', 'prouni_preset');
RESET ROLE;
```

### Create Schemas

To create the schemas and tables, connect to the `prouni_prouni` database using `psql` and execute the following command.

```postgresql
\i ./database/schemas.sql
```

### Populate

To populate the database, create an `.env` file in the `database/populate` directory and fill it as appropriate.
There is a sample `.env.example` file to guide you.
For copying the example file, you can use the following command:

```bash
cp ./database/populate/.env.example ./database/populate/.env
```

You must download the ODS and CSV files to appropriate directories as follows.

```none
project_root
└── sources
    ├── cor
    │   ├── metropolitanos.ods
    │   └── todos.ods
    ├── idade
    │   └── todos.ods
    └── prouni
        ├── 2010.csv
        └── 2020.csv
```

Then, enter the directory of the script you want to run, and execute it with python.
The scripts must be run in the following order to ensure that all dependencies are met.

```bash
cd ./database/populate/census
python3 metropolitan_cities.py
python3 all_cities.py
python3 color_data.py
python3 age_data.py
cd ../../..
```

```bash
cd ./database/populate/prouni
python3 institutions_and_courses.py
python3 concessions_2010.py
python3 concessions_2020.py
cd ../../..
```

### Views

Access the `views` directory, enter `psql` connected to the `prouni_prouni` database, and execute each file in this order.

```bash
cd ./database/views
psql -h <hostname> -U <username> -d prouni_prouni
```

```postgresql
\i city_demographics.sql
\i city_demographics_for_concessions.sql
\i city_demographics_combined.sql
\i state_demographics_combined.sql
\i region_demographics_combined.sql
\i country_demographics_combined.sql
```
