DROP MATERIALIZED VIEW IF EXISTS public.city_demographics CASCADE;
CREATE MATERIALIZED VIEW public.city_demographics AS
WITH census_data AS (
    SELECT 
        c.id,
        c.ibge_code,
        c.federative_unit AS uf,
        c.name AS city_name,
        c.is_metropolitan,
        
        -- 2010 raw data
        COALESCE(pop2010.total_population, 0) AS total_2010,
        COALESCE(pop2010.young_population, 0) AS young_2010,
        COALESCE(pop2010.white_population, 0) AS white_2010,
        COALESCE(pop2010.black_population, 0) AS black_2010,
        COALESCE(pop2010.parda_population, 0) AS parda_2010,
        COALESCE(pop2010.yellow_population, 0) AS yellow_2010,
        COALESCE(pop2010.indigenous_population, 0) AS indigenous_2010,
        
        -- 2022 raw data
        COALESCE(pop2022.total_population, 0) AS total_2022,
        COALESCE(pop2022.young_population, 0) AS young_2022,
        COALESCE(pop2022.white_population, 0) AS white_2022,
        COALESCE(pop2022.black_population, 0) AS black_2022,
        COALESCE(pop2022.parda_population, 0) AS parda_2022,
        COALESCE(pop2022.yellow_population, 0) AS yellow_2022,
        COALESCE(pop2022.indigenous_population, 0) AS indigenous_2022
    FROM census.city c
    LEFT JOIN census.census pop2010 ON c.id = pop2010.city_id AND pop2010.year = 2010
    LEFT JOIN census.census pop2022 ON c.id = pop2022.city_id AND pop2022.year = 2022
)
SELECT 
    id,
    ibge_code,
    uf,
    city_name,
    is_metropolitan,
    
    -- 2010 Census Data
    total_2010 AS total_population_2010,
    young_2010 AS young_population_2010,
    (total_2010 - young_2010) AS not_young_population_2010,
    white_2010 AS white_population_2010,
    black_2010 AS black_population_2010,
    parda_2010 AS parda_population_2010,
    yellow_2010 AS yellow_population_2010,
    indigenous_2010 AS indigenous_population_2010,
    (black_2010 + parda_2010 + indigenous_2010) AS with_quotas_population_2010,
    (total_2010 - (black_2010 + parda_2010 + indigenous_2010)) AS without_quotas_population_2010,

    -- 2010 Percentages
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(young_2010::numeric / total_2010 * 100, 5) END AS young_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((total_2010 - young_2010)::numeric / total_2010 * 100, 5) END AS not_young_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(white_2010::numeric / total_2010 * 100, 5) END AS white_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(black_2010::numeric / total_2010 * 100, 5) END AS black_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(parda_2010::numeric / total_2010 * 100, 5) END AS parda_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(yellow_2010::numeric / total_2010 * 100, 5) END AS yellow_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(indigenous_2010::numeric / total_2010 * 100, 5) END AS indigenous_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((black_2010 + parda_2010 + indigenous_2010)::numeric / total_2010 * 100, 5) END AS with_quotas_population_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((total_2010 - (black_2010 + parda_2010 + indigenous_2010))::numeric / total_2010 * 100, 5) END AS without_quotas_population_percent_2010,
    
    -- 2022 Census Data
    total_2022 AS total_population_2022,
    young_2022 AS young_population_2022,
    (total_2022 - young_2022) AS not_young_population_2022,
    white_2022 AS white_population_2022,
    black_2022 AS black_population_2022,
    parda_2022 AS parda_population_2022,
    yellow_2022 AS yellow_population_2022,
    indigenous_2022 AS indigenous_population_2022,
    (black_2022 + parda_2022 + indigenous_2022) AS with_quotas_population_2022,
    (total_2022 - (black_2022 + parda_2022 + indigenous_2022)) AS without_quotas_population_2022,

    -- 2022 Percentages
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(young_2022::numeric / total_2022 * 100, 5) END AS young_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND((total_2022 - young_2022)::numeric / total_2022 * 100, 5) END AS not_young_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(white_2022::numeric / total_2022 * 100, 5) END AS white_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(black_2022::numeric / total_2022 * 100, 5) END AS black_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(parda_2022::numeric / total_2022 * 100, 5) END AS parda_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(yellow_2022::numeric / total_2022 * 100, 5) END AS yellow_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND(indigenous_2022::numeric / total_2022 * 100, 5) END AS indigenous_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND((black_2022 + parda_2022 + indigenous_2022)::numeric / total_2022 * 100, 5) END AS with_quotas_population_percent_2022,
    CASE WHEN total_2022 = 0 THEN 0 ELSE ROUND((total_2022 - (black_2022 + parda_2022 + indigenous_2022))::numeric / total_2022 * 100, 5) END AS without_quotas_population_percent_2022
    
FROM census_data
ORDER BY uf, city_name;

-- Create indexes for better performance
CREATE INDEX idx_city_demographics_uf ON public.city_demographics(uf);
CREATE INDEX idx_city_demographics_ibge ON public.city_demographics(ibge_code);
