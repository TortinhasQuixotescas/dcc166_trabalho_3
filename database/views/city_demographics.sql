DROP MATERIALIZED VIEW IF EXISTS public.city_demographics;
CREATE MATERIALIZED VIEW public.city_demographics AS
SELECT
    c.id,
    c.ibge_code,
    c.federative_unit AS uf,
    c.name AS city_name,
    c.is_metropolitan,
    
    -- 2010 Census Data
    COALESCE(pop2010.total_population, 0) AS total_population_2010,
    COALESCE(pop2010.young_population, 0) AS young_population_2010,
    COALESCE(pop2010.white_population, 0) AS white_population_2010,
    COALESCE(pop2010.black_population, 0) AS black_population_2010,
    COALESCE(pop2010.parda_population, 0) AS parda_population_2010,
    COALESCE(pop2010.yellow_population, 0) AS yellow_population_2010,
    COALESCE(pop2010.indigenous_population, 0) AS indigenous_population_2010,
    COALESCE(pop2010.black_population + pop2010.parda_population + pop2010.indigenous_population, 0) AS with_quotas_population_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.young_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS young_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.white_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS white_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.black_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS black_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.parda_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS parda_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.yellow_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS yellow_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2010.indigenous_population, 0)::numeric / COALESCE(pop2010.total_population, 1) * 100, 5) 
    END AS indigenous_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN 0
        ELSE ROUND((COALESCE(pop2010.black_population + pop2010.parda_population + pop2010.indigenous_population, 0))::numeric / 
             COALESCE(pop2010.total_population, 1) * 100, 5)
    END AS with_quotas_population_percent_2010,

    CASE 
        WHEN COALESCE(pop2010.total_population, 0) = 0 THEN NULL
        ELSE ROUND((COALESCE(pop2010.total_population, 0)::numeric - 
             COALESCE(pop2010.black_population + pop2010.parda_population + pop2010.indigenous_population, 0)::numeric) / 
             COALESCE(pop2010.total_population, 1) * 100, 5)
    END AS without_quotas_population_percent_2010, 
    
    -- 2022 Census Data
    COALESCE(pop2022.total_population, 0) AS total_population_2022,
    COALESCE(pop2022.young_population, 0) AS young_population_2022,
    COALESCE(pop2022.white_population, 0) AS white_population_2022,
    COALESCE(pop2022.black_population, 0) AS black_population_2022,
    COALESCE(pop2022.parda_population, 0) AS parda_population_2022,
    COALESCE(pop2022.yellow_population, 0) AS yellow_population_2022,
    COALESCE(pop2022.indigenous_population, 0) AS indigenous_population_2022,
    COALESCE(pop2022.black_population + pop2022.parda_population + pop2022.indigenous_population, 0) AS with_quotas_population_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.young_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS young_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.white_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS white_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.black_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS black_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.parda_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS parda_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.yellow_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS yellow_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(pop2022.indigenous_population, 0)::numeric / COALESCE(pop2022.total_population, 1) * 100, 5) 
    END AS indigenous_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN 0
        ELSE ROUND((COALESCE(pop2022.black_population + pop2022.parda_population + pop2022.indigenous_population, 0))::numeric / 
             COALESCE(pop2022.total_population, 1) * 100, 5)
    END AS with_quotas_population_percent_2022,

    CASE 
        WHEN COALESCE(pop2022.total_population, 0) = 0 THEN NULL
        ELSE ROUND((COALESCE(pop2022.total_population, 0)::numeric - 
             COALESCE(pop2022.black_population + pop2022.parda_population + pop2022.indigenous_population, 0)::numeric) / 
             COALESCE(pop2022.total_population, 1) * 100, 5)
    END AS without_quotas_population_percent_2022
    
FROM census.city c
LEFT JOIN census.census pop2010 ON c.id = pop2010.city_id AND pop2010.year = 2010
LEFT JOIN census.census pop2022 ON c.id = pop2022.city_id AND pop2022.year = 2022
ORDER BY c.federative_unit, c.name;
