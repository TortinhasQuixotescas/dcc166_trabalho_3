DROP MATERIALIZED VIEW IF EXISTS public.city_demographics_combined CASCADE;
CREATE MATERIALIZED VIEW public.city_demographics_combined AS
SELECT 
    c.id,
    c.ibge_code,
    c.federative_unit AS uf,
    c.name AS city_name,
    c.is_metropolitan,
    
    -- 2010 Census Data
    pop.total_population_2010,
    pop.young_population_2010,
    pop.not_young_population_2010,
    pop.white_population_2010,
    pop.black_population_2010,
    pop.parda_population_2010,
    pop.yellow_population_2010,
    pop.indigenous_population_2010,
    pop.with_quotas_population_2010,
    pop.without_quotas_population_2010,
    pop.young_population_percent_2010,
    pop.not_young_population_percent_2010,
    pop.white_population_percent_2010,
    pop.black_population_percent_2010,
    pop.parda_population_percent_2010,
    pop.yellow_population_percent_2010,
    pop.indigenous_population_percent_2010,
    pop.with_quotas_population_percent_2010,
    pop.without_quotas_population_percent_2010,
    
    -- 2022 Census Data
    pop.total_population_2022,
    pop.young_population_2022,
    pop.not_young_population_2022,
    pop.white_population_2022,
    pop.black_population_2022,
    pop.parda_population_2022,
    pop.yellow_population_2022,
    pop.indigenous_population_2022,
    pop.with_quotas_population_2022,
    pop.without_quotas_population_2022,
    pop.young_population_percent_2022,
    pop.not_young_population_percent_2022,
    pop.white_population_percent_2022,
    pop.black_population_percent_2022,
    pop.parda_population_percent_2022,
    pop.yellow_population_percent_2022,
    pop.indigenous_population_percent_2022,
    pop.with_quotas_population_percent_2022,
    pop.without_quotas_population_percent_2022,
    
    -- 2010 Concessions Data
    con.total_concessions_2010,
    con.young_concessions_2010,
    con.not_young_concessions_2010,
    con.white_concessions_2010,
    con.black_concessions_2010,
    con.parda_concessions_2010,
    con.yellow_concessions_2010,
    con.indigenous_concessions_2010,
    con.with_quotas_concessions_2010,
    con.without_quotas_concessions_2010,
    con.young_concessions_percent_2010,
    con.not_young_concessions_percent_2010,
    con.white_concessions_percent_2010,
    con.black_concessions_percent_2010,
    con.parda_concessions_percent_2010,
    con.yellow_concessions_percent_2010,
    con.indigenous_concessions_percent_2010,
    con.with_quotas_concessions_percent_2010,
    con.without_quotas_concessions_percent_2010,
    
    -- 2020 Concessions Data
    con.total_concessions_2020,
    con.young_concessions_2020,
    con.not_young_concessions_2020,
    con.white_concessions_2020,
    con.black_concessions_2020,
    con.parda_concessions_2020,
    con.yellow_concessions_2020,
    con.indigenous_concessions_2020,
    con.with_quotas_concessions_2020,
    con.without_quotas_concessions_2020,
    con.young_concessions_percent_2020,
    con.not_young_concessions_percent_2020,
    con.white_concessions_percent_2020,
    con.black_concessions_percent_2020,
    con.parda_concessions_percent_2020,
    con.yellow_concessions_percent_2020,
    con.indigenous_concessions_percent_2020,
    con.with_quotas_concessions_percent_2020,
    con.without_quotas_concessions_percent_2020,
    
    -- Combined metrics
    CASE 
        WHEN pop.total_population_2010 = 0 THEN 0
        ELSE ROUND(con.total_concessions_2010::numeric / pop.total_population_2010, 5)
    END AS concessions_per_population_2010,
    
    CASE 
        WHEN pop.total_population_2022 = 0 THEN 0
        ELSE ROUND(con.total_concessions_2020::numeric / pop.total_population_2022, 5)
    END AS concessions_per_population_2020,
    
    CASE 
        WHEN pop.with_quotas_population_2010 = 0 THEN 0
        ELSE ROUND(con.with_quotas_concessions_2010::numeric / pop.with_quotas_population_2010, 5)
    END AS with_quotas_concessions_per_population_2010,
    
    CASE 
        WHEN pop.with_quotas_population_2022 = 0 THEN 0
        ELSE ROUND(con.with_quotas_concessions_2020::numeric / pop.with_quotas_population_2022, 5)
    END AS with_quotas_concessions_per_population_2020,
    
    CASE 
        WHEN pop.without_quotas_population_2010 = 0 THEN 0
        ELSE ROUND(con.without_quotas_concessions_2010::numeric / pop.without_quotas_population_2010, 5)
    END AS without_quotas_concessions_per_population_2010,
    
    CASE 
        WHEN pop.without_quotas_population_2022 = 0 THEN 0
        ELSE ROUND(con.without_quotas_concessions_2020::numeric / pop.without_quotas_population_2022, 5)
    END AS without_quotas_concessions_per_population_2020
 
FROM census.city c
LEFT JOIN public.city_demographics pop ON c.id = pop.id
LEFT JOIN public.city_demographics_for_concessions con ON c.id = con.id
ORDER BY c.federative_unit, c.name;

-- Create indexes for better performance
CREATE INDEX idx_city_demographics_combined_uf ON public.city_demographics_combined(uf);
CREATE INDEX idx_city_demographics_combined_ibge ON public.city_demographics_combined(ibge_code);
