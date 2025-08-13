-- Create the enumeration type for color
CREATE TYPE color AS ENUM (
    'BRANCA',
    'PRETA',
    'PARDA',
    'AMARELA',
    'INDIGENA',
    'NAO_INFORMADA'
);

-- Create enumeration type for Brazilian federative units
CREATE TYPE federative_unit AS ENUM (
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
);

-- Create census schema and tables
CREATE SCHEMA census;

CREATE TABLE census.city (
    id SERIAL PRIMARY KEY,
    ibge_code CHAR(7) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    federative_unit federative_unit NOT NULL,
    is_metropolitan BOOLEAN NOT NULL,
    CONSTRAINT unique_city_name_uf UNIQUE (name, federative_unit),
    CONSTRAINT valid_ibge_code CHECK (ibge_code ~ '^[0-9]{7}$')
);

CREATE TABLE census.census (
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL REFERENCES census.city(id),
    year INTEGER NOT NULL,
    total_population INTEGER NOT NULL DEFAULT 0,
    young_population INTEGER NOT NULL DEFAULT 0,
    white_population INTEGER NOT NULL DEFAULT 0,
    black_population INTEGER NOT NULL DEFAULT 0,
    parda_population INTEGER NOT NULL DEFAULT 0,
    yellow_population INTEGER NOT NULL DEFAULT 0,
    indigenous_population INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT unique_city_year UNIQUE (city_id, year),
    CONSTRAINT valid_year CHECK (year BETWEEN 1900 AND 2100)
);

-- Create prouni schema and tables
CREATE SCHEMA prouni;

CREATE TABLE prouni.institution (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    e_mec_code VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE prouni.course (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER NOT NULL REFERENCES prouni.institution(id),
    name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_course_institution UNIQUE (institution_id, name)
);

CREATE TABLE prouni.concession (
    id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES prouni.course(id),
    city_id INTEGER NOT NULL REFERENCES census.city(id),
    year INTEGER NOT NULL,
    color COLOR NOT NULL,
    birth_date DATE NOT NULL,
    CONSTRAINT valid_concession_year CHECK (year BETWEEN 2000 AND 2100),
    CONSTRAINT valid_birth_date CHECK (birth_date BETWEEN '1900-01-01' AND CURRENT_DATE)
);

-- Create additional indexes for better performance
CREATE INDEX idx_census_city ON census.census(city_id);
CREATE INDEX idx_city_ibge_code ON census.city(ibge_code);
CREATE INDEX idx_course_institution ON prouni.course(institution_id);
CREATE INDEX idx_concession_course ON prouni.concession(course_id);
CREATE INDEX idx_concession_city ON prouni.concession(city_id);
