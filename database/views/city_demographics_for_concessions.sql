DROP MATERIALIZED VIEW IF EXISTS public.city_demographics_for_concessions CASCADE;
CREATE MATERIALIZED VIEW public.city_demographics_for_concessions AS
WITH concessions_data AS (
    SELECT
        c.id,
        c.ibge_code,
        c.federative_unit AS uf,
        c.name AS city_name,
        c.is_metropolitan,
        
        -- 2010 raw counts
        COUNT(DISTINCT CASE WHEN con.year = 2010 THEN con.id END) AS total_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND EXTRACT(YEAR FROM con.birth_date) >= 1991 THEN con.id END) AS young_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND con.color = 'BRANCA' THEN con.id END) AS white_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND con.color = 'PRETA' THEN con.id END) AS black_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND con.color = 'PARDA' THEN con.id END) AS parda_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND con.color = 'AMARELA' THEN con.id END) AS yellow_2010,
        COUNT(DISTINCT CASE WHEN con.year = 2010 AND con.color = 'INDIGENA' THEN con.id END) AS indigenous_2010,
        
        -- 2020 raw counts
        COUNT(DISTINCT CASE WHEN con.year = 2020 THEN con.id END) AS total_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND EXTRACT(YEAR FROM con.birth_date) >= 2001 THEN con.id END) AS young_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND con.color = 'BRANCA' THEN con.id END) AS white_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND con.color = 'PRETA' THEN con.id END) AS black_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND con.color = 'PARDA' THEN con.id END) AS parda_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND con.color = 'AMARELA' THEN con.id END) AS yellow_2020,
        COUNT(DISTINCT CASE WHEN con.year = 2020 AND con.color = 'INDIGENA' THEN con.id END) AS indigenous_2020
    FROM census.city c
    LEFT JOIN prouni.concession con ON c.id = con.city_id AND con.year IN (2010, 2020)
    GROUP BY c.id, c.ibge_code, c.federative_unit, c.name, c.is_metropolitan
)
SELECT
    id,
    ibge_code,
    uf,
    city_name,
    is_metropolitan,
    
    -- 2010 Concessions Data
    total_2010 AS total_concessions_2010,
    young_2010 AS young_concessions_2010,
    (total_2010 - young_2010) AS not_young_concessions_2010,
    white_2010 AS white_concessions_2010,
    black_2010 AS black_concessions_2010,
    parda_2010 AS parda_concessions_2010,
    yellow_2010 AS yellow_concessions_2010,
    indigenous_2010 AS indigenous_concessions_2010,
    (black_2010 + parda_2010 + indigenous_2010) AS with_quotas_concessions_2010,
    (total_2010 - (black_2010 + parda_2010 + indigenous_2010)) AS without_quotas_concessions_2010,

    -- 2010 Percentages
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(young_2010::numeric / total_2010 * 100, 5) END AS young_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((total_2010 - young_2010)::numeric / total_2010 * 100, 5) END AS not_young_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(white_2010::numeric / total_2010 * 100, 5) END AS white_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(black_2010::numeric / total_2010 * 100, 5) END AS black_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(parda_2010::numeric / total_2010 * 100, 5) END AS parda_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(yellow_2010::numeric / total_2010 * 100, 5) END AS yellow_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND(indigenous_2010::numeric / total_2010 * 100, 5) END AS indigenous_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((black_2010 + parda_2010 + indigenous_2010)::numeric / total_2010 * 100, 5) END AS with_quotas_concessions_percent_2010,
    CASE WHEN total_2010 = 0 THEN 0 ELSE ROUND((total_2010 - (black_2010 + parda_2010 + indigenous_2010))::numeric / total_2010 * 100, 5) END AS without_quotas_concessions_percent_2010,

    -- 2020 Concessions Data
    total_2020 AS total_concessions_2020,
    young_2020 AS young_concessions_2020,
    (total_2020 - young_2020) AS not_young_concessions_2020,
    white_2020 AS white_concessions_2020,
    black_2020 AS black_concessions_2020,
    parda_2020 AS parda_concessions_2020,
    yellow_2020 AS yellow_concessions_2020,
    indigenous_2020 AS indigenous_concessions_2020,
    (black_2020 + parda_2020 + indigenous_2020) AS with_quotas_concessions_2020,
    (total_2020 - (black_2020 + parda_2020 + indigenous_2020)) AS without_quotas_concessions_2020,

    -- 2020 Percentages
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(young_2020::numeric / total_2020 * 100, 5) END AS young_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND((total_2020 - young_2020)::numeric / total_2020 * 100, 5) END AS not_young_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(white_2020::numeric / total_2020 * 100, 5) END AS white_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(black_2020::numeric / total_2020 * 100, 5) END AS black_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(parda_2020::numeric / total_2020 * 100, 5) END AS parda_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(yellow_2020::numeric / total_2020 * 100, 5) END AS yellow_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND(indigenous_2020::numeric / total_2020 * 100, 5) END AS indigenous_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND((black_2020 + parda_2020 + indigenous_2020)::numeric / total_2020 * 100, 5) END AS with_quotas_concessions_percent_2020,
    CASE WHEN total_2020 = 0 THEN 0 ELSE ROUND((total_2020 - (black_2020 + parda_2020 + indigenous_2020))::numeric / total_2020 * 100, 5) END AS without_quotas_concessions_percent_2020

FROM concessions_data
ORDER BY uf, city_name;

-- Create indexes for better performance
CREATE INDEX idx_city_demographics_for_concessions_uf ON public.city_demographics_for_concessions(uf);
CREATE INDEX idx_city_demographics_for_concessions_ibge ON public.city_demographics_for_concessions(ibge_code);
