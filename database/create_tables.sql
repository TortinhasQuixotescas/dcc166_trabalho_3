CREATE TABLE IF NOT EXISTS city(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    federative_unit CHAR(2) NOT NULL CHECK (
        federative_unit IN (
            'AC',
            'AL',
            'AP',
            'AM',
            'BA',
            'CE',
            'DF',
            'ES',
            'GO',
            'MA',
            'MT',
            'MS',
            'MG',
            'PA',
            'PB',
            'PR',
            'PE',
            'PI',
            'RJ',
            'RN',
            'RS',
            'RO',
            'RR',
            'SC',
            'SP',
            'SE',
            'TO'
        )
    )
);
CREATE TABLE IF NOT EXISTS institution(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    e_mec_code VARCHAR(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS course(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    institution_id INT NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES institution(id)
);
CREATE TABLE IF NOT EXISTS concession(
    id SERIAL PRIMARY KEY,
    year INT NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES course(id),
    -- Race of the student: 'B' for "Branca", 'P' for "Preta", 'D' for "Parda", 'I' for "Indígena", 'A' for "Amarela", and 'N' for "Não Informada"
    beneficiary_race CHAR(1) NOT NULL CHECK (
        beneficiary_race IN ('B', 'P', 'D', 'I', 'A', 'N')
    ),
    beneficiary_birth_date DATE NOT NULL,
    beneficiary_city_id INT NOT NULL,
    FOREIGN KEY (beneficiary_city_id) REFERENCES city(id)
);
