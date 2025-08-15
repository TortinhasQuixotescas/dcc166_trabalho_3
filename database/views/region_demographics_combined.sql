DROP MATERIALIZED VIEW IF EXISTS public.region_demographics_combined CASCADE;
CREATE MATERIALIZED VIEW public.region_demographics_combined AS
WITH region_mapping AS (
    SELECT 
        uf,
        CASE 
            WHEN uf IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'NORTH'
            WHEN uf IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'NORTHEAST'
            WHEN uf IN ('ES', 'MG', 'RJ', 'SP') THEN 'SOUTHEAST'
            WHEN uf IN ('PR', 'RS', 'SC') THEN 'SOUTH'
            WHEN uf IN ('DF', 'GO', 'MT', 'MS') THEN 'CENTER_WEST'
        END AS region
    FROM (SELECT DISTINCT uf FROM public.city_demographics_combined) states
),
region_data AS (
    SELECT 
        rm.region,
        
        -- Population totals by metropolitan status (2010)
        SUM(CASE WHEN cdc.is_metropolitan THEN cdc.total_population_2010 ELSE 0 END) AS metropolitan_population_2010,
        SUM(CASE WHEN NOT cdc.is_metropolitan THEN cdc.total_population_2010 ELSE 0 END) AS not_metropolitan_population_2010,
        SUM(cdc.total_population_2010) AS total_population_2010,
        
        -- Population totals by metropolitan status (2022)
        SUM(CASE WHEN cdc.is_metropolitan THEN cdc.total_population_2022 ELSE 0 END) AS metropolitan_population_2022,
        SUM(CASE WHEN NOT cdc.is_metropolitan THEN cdc.total_population_2022 ELSE 0 END) AS not_metropolitan_population_2022,
        SUM(cdc.total_population_2022) AS total_population_2022,
        
        -- Concession totals by metropolitan status (2010)
        SUM(CASE WHEN cdc.is_metropolitan THEN cdc.total_concessions_2010 ELSE 0 END) AS metropolitan_concessions_2010,
        SUM(CASE WHEN NOT cdc.is_metropolitan THEN cdc.total_concessions_2010 ELSE 0 END) AS not_metropolitan_concessions_2010,
        SUM(cdc.total_concessions_2010) AS total_concessions_2010,
        
        -- Concession totals by metropolitan status (2020)
        SUM(CASE WHEN cdc.is_metropolitan THEN cdc.total_concessions_2020 ELSE 0 END) AS metropolitan_concessions_2020,
        SUM(CASE WHEN NOT cdc.is_metropolitan THEN cdc.total_concessions_2020 ELSE 0 END) AS not_metropolitan_concessions_2020,
        SUM(cdc.total_concessions_2020) AS total_concessions_2020,
        
        -- Demographic breakdowns (2010)
        SUM(cdc.young_population_2010) AS young_population_2010,
        SUM(cdc.not_young_population_2010) AS not_young_population_2010,
        SUM(cdc.white_population_2010) AS white_population_2010,
        SUM(cdc.black_population_2010) AS black_population_2010,
        SUM(cdc.parda_population_2010) AS parda_population_2010,
        SUM(cdc.yellow_population_2010) AS yellow_population_2010,
        SUM(cdc.indigenous_population_2010) AS indigenous_population_2010,
        SUM(cdc.with_quotas_population_2010) AS with_quotas_population_2010,
        SUM(cdc.without_quotas_population_2010) AS without_quotas_population_2010,

        -- Demographic breakdowns (2022)
        SUM(cdc.young_population_2022) AS young_population_2022,
        SUM(cdc.not_young_population_2022) AS not_young_population_2022,
        SUM(cdc.white_population_2022) AS white_population_2022,
        SUM(cdc.black_population_2022) AS black_population_2022,
        SUM(cdc.parda_population_2022) AS parda_population_2022,
        SUM(cdc.yellow_population_2022) AS yellow_population_2022,
        SUM(cdc.indigenous_population_2022) AS indigenous_population_2022,
        SUM(cdc.with_quotas_population_2022) AS with_quotas_population_2022,
        SUM(cdc.without_quotas_population_2022) AS without_quotas_population_2022,
        
        -- Concession breakdowns (2010)
        SUM(cdc.young_concessions_2010) AS young_concessions_2010,
        SUM(cdc.not_young_concessions_2010) AS not_young_concessions_2010,
        SUM(cdc.white_concessions_2010) AS white_concessions_2010,
        SUM(cdc.black_concessions_2010) AS black_concessions_2010,
        SUM(cdc.parda_concessions_2010) AS parda_concessions_2010,
        SUM(cdc.yellow_concessions_2010) AS yellow_concessions_2010,
        SUM(cdc.indigenous_concessions_2010) AS indigenous_concessions_2010,
        SUM(cdc.with_quotas_concessions_2010) AS with_quotas_concessions_2010,
        SUM(cdc.without_quotas_concessions_2010) AS without_quotas_concessions_2010,
        
        -- Concession breakdowns (2020)
        SUM(cdc.young_concessions_2020) AS young_concessions_2020,
        SUM(cdc.not_young_concessions_2020) AS not_young_concessions_2020,
        SUM(cdc.white_concessions_2020) AS white_concessions_2020,
        SUM(cdc.black_concessions_2020) AS black_concessions_2020,
        SUM(cdc.parda_concessions_2020) AS parda_concessions_2020,
        SUM(cdc.yellow_concessions_2020) AS yellow_concessions_2020,
        SUM(cdc.indigenous_concessions_2020) AS indigenous_concessions_2020,
        SUM(cdc.with_quotas_concessions_2020) AS with_quotas_concessions_2020,
        SUM(cdc.without_quotas_concessions_2020) AS without_quotas_concessions_2020
        
    FROM public.city_demographics_combined cdc
    JOIN region_mapping rm ON cdc.uf = rm.uf
    GROUP BY rm.region
)
SELECT 
    region,
    
    -- 2010 Population Data
    total_population_2010,
    metropolitan_population_2010,
    not_metropolitan_population_2010,
    young_population_2010,
    not_young_population_2010,
    white_population_2010,
    black_population_2010,
    parda_population_2010,
    yellow_population_2010,
    indigenous_population_2010,
    with_quotas_population_2010,
    without_quotas_population_2010,
    
    -- 2010 Population Percentages
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(metropolitan_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS metropolitan_population_percent_2010,
    
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(not_metropolitan_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS not_metropolitan_population_percent_2010,
    
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(young_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS young_population_percent_2010,
    
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(not_young_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS not_young_population_percent_2010,

    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(white_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS white_population_percent_2010,

    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(black_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS black_population_percent_2010,

    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(parda_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS parda_population_percent_2010,

    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(yellow_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS yellow_population_percent_2010,

    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(indigenous_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS indigenous_population_percent_2010,
    
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(with_quotas_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS with_quotas_population_percent_2010,
    
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(without_quotas_population_2010::numeric / total_population_2010 * 100, 5) 
    END AS without_quotas_population_percent_2010,
    
    -- 2022 Population Data
    total_population_2022,
    metropolitan_population_2022,
    not_metropolitan_population_2022,
    young_population_2022,
    not_young_population_2022,
    white_population_2022,
    black_population_2022,
    parda_population_2022,
    yellow_population_2022,
    indigenous_population_2022,
    with_quotas_population_2022,
    without_quotas_population_2022,
    
    -- 2022 Population Percentages
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(metropolitan_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS metropolitan_population_percent_2022,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(not_metropolitan_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS not_metropolitan_population_percent_2022,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(young_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS young_population_percent_2022,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(not_young_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS not_young_population_percent_2022,

    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(white_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS white_population_percent_2022,

    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(black_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS black_population_percent_2022,

    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(parda_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS parda_population_percent_2022,

    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(yellow_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS yellow_population_percent_2022,

    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(indigenous_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS indigenous_population_percent_2022,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(with_quotas_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS with_quotas_population_percent_2022,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(without_quotas_population_2022::numeric / total_population_2022 * 100, 5) 
    END AS without_quotas_population_percent_2022,
    
    -- 2010 Concessions Data
    total_concessions_2010,
    metropolitan_concessions_2010,
    not_metropolitan_concessions_2010,
    young_concessions_2010,
    not_young_concessions_2010,
    white_concessions_2010,
    black_concessions_2010,
    parda_concessions_2010,
    yellow_concessions_2010,
    indigenous_concessions_2010,
    with_quotas_concessions_2010,
    without_quotas_concessions_2010,
    
    -- 2010 Concessions Percentages
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(metropolitan_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS metropolitan_concessions_percent_2010,
    
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(not_metropolitan_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS not_metropolitan_concessions_percent_2010,
    
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(young_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS young_concessions_percent_2010,
    
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(not_young_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS not_young_concessions_percent_2010,

    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(white_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS white_concessions_percent_2010,

    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(black_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS black_concessions_percent_2010,

    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(parda_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS parda_concessions_percent_2010,

    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(yellow_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS yellow_concessions_percent_2010,

    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(indigenous_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS indigenous_concessions_percent_2010,
    
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(with_quotas_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS with_quotas_concessions_percent_2010,
    
    CASE WHEN total_concessions_2010 = 0 THEN 0 
         ELSE ROUND(without_quotas_concessions_2010::numeric / total_concessions_2010 * 100, 5) 
    END AS without_quotas_concessions_percent_2010,
    
    -- 2020 Concessions Data
    total_concessions_2020,
    metropolitan_concessions_2020,
    not_metropolitan_concessions_2020,
    young_concessions_2020,
    not_young_concessions_2020,
    white_concessions_2020,
    black_concessions_2020,
    parda_concessions_2020,
    yellow_concessions_2020,
    indigenous_concessions_2020,
    with_quotas_concessions_2020,
    without_quotas_concessions_2020,
    
    -- 2020 Concessions Percentages
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(metropolitan_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS metropolitan_concessions_percent_2020,
    
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(not_metropolitan_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS not_metropolitan_concessions_percent_2020,
    
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(young_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS young_concessions_percent_2020,
    
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(not_young_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS not_young_concessions_percent_2020,

    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(white_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS white_concessions_percent_2020,

    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(black_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS black_concessions_percent_2020,

    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(parda_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS parda_concessions_percent_2020,

    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(yellow_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS yellow_concessions_percent_2020,

    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(indigenous_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS indigenous_concessions_percent_2020,
    
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(with_quotas_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS with_quotas_concessions_percent_2020,
    
    CASE WHEN total_concessions_2020 = 0 THEN 0 
         ELSE ROUND(without_quotas_concessions_2020::numeric / total_concessions_2020 * 100, 5) 
    END AS without_quotas_concessions_percent_2020,
    
    -- Combined metrics
    CASE WHEN total_population_2010 = 0 THEN 0 
         ELSE ROUND(total_concessions_2010::numeric / total_population_2010, 5) 
    END AS concessions_per_population_2010,
    
    CASE WHEN total_population_2022 = 0 THEN 0 
         ELSE ROUND(total_concessions_2020::numeric / total_population_2022, 5) 
    END AS concessions_per_population_2020,
    
    CASE WHEN with_quotas_population_2010 = 0 THEN 0 
         ELSE ROUND(with_quotas_concessions_2010::numeric / with_quotas_population_2010, 5) 
    END AS with_quotas_concessions_per_population_2010,
    
    CASE WHEN with_quotas_population_2022 = 0 THEN 0 
         ELSE ROUND(with_quotas_concessions_2020::numeric / with_quotas_population_2022, 5) 
    END AS with_quotas_concessions_per_population_2020,

    CASE WHEN without_quotas_population_2010 = 0 THEN 0 
         ELSE ROUND(without_quotas_concessions_2010::numeric / without_quotas_population_2010, 5) 
    END AS without_quotas_concessions_per_population_2010,
    
    CASE WHEN without_quotas_population_2022 = 0 THEN 0 
         ELSE ROUND(without_quotas_concessions_2020::numeric / without_quotas_population_2022, 5) 
    END AS without_quotas_concessions_per_population_2020
    
FROM region_data
ORDER BY 
    CASE region
        WHEN 'NORTH' THEN 1
        WHEN 'NORTHEAST' THEN 2
        WHEN 'SOUTHEAST' THEN 3
        WHEN 'SOUTH' THEN 4
        WHEN 'CENTER_WEST' THEN 5
    END;

-- Create index for better performance
CREATE INDEX idx_region_demographics_combined_region ON public.region_demographics_combined(region);
