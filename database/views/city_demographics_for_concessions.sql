DROP MATERIALIZED VIEW IF EXISTS public.city_demographics_for_concessions;
CREATE MATERIALIZED VIEW public.city_demographics_for_concessions AS
SELECT
    c.id,
    c.ibge_code,
    c.federative_unit AS uf,
    c.name AS city_name,
    c.is_metropolitan,
    
    -- 2010 Concessions Data
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) AS total_concessions_2010,
    
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND 
          EXTRACT(YEAR FROM con2010.birth_date) >= 1991 THEN con2010.id END) AS young_concessions_2010,
    
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'BRANCA' THEN con2010.id END) AS white_concessions_2010,
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'PRETA' THEN con2010.id END) AS black_concessions_2010,
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'PARDA' THEN con2010.id END) AS parda_concessions_2010,
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'AMARELA' THEN con2010.id END) AS yellow_concessions_2010,
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'INDIGENA' THEN con2010.id END) AS indigenous_concessions_2010,
    
    COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND 
          con2010.color IN ('PRETA', 'PARDA', 'INDIGENA') THEN con2010.id END) AS with_quotas_concessions_2010,

    -- 2010 Percentages
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND 
              EXTRACT(YEAR FROM con2010.birth_date) >= 1991 THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS young_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'BRANCA' THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS white_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'PRETA' THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS black_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'PARDA' THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS parda_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'AMARELA' THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS yellow_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND con2010.color = 'INDIGENA' THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS indigenous_concessions_percent_2010,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2010.year = 2010 AND 
              con2010.color IN ('PRETA', 'PARDA', 'INDIGENA') THEN con2010.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2010.year = 2010 THEN con2010.id END) * 100, 5)
    END AS with_quotas_concessions_percent_2010,

    -- 2020 Concessions Data
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) AS total_concessions_2020,
    
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND 
          EXTRACT(YEAR FROM con2020.birth_date) >= 2001 THEN con2020.id END) AS young_concessions_2020,
    
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'BRANCA' THEN con2020.id END) AS white_concessions_2020,
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'PRETA' THEN con2020.id END) AS black_concessions_2020,
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'PARDA' THEN con2020.id END) AS parda_concessions_2020,
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'AMARELA' THEN con2020.id END) AS yellow_concessions_2020,
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'INDIGENA' THEN con2020.id END) AS indigenous_concessions_2020,
    
    COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND 
          con2020.color IN ('PRETA', 'PARDA', 'INDIGENA') THEN con2020.id END) AS with_quotas_concessions_2020,

    -- 2020 Percentages
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND 
              EXTRACT(YEAR FROM con2020.birth_date) >= 2001 THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS young_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'BRANCA' THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS white_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'PRETA' THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS black_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'PARDA' THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS parda_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'AMARELA' THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS yellow_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND con2020.color = 'INDIGENA' THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS indigenous_concessions_percent_2020,

    CASE 
        WHEN COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) = 0 THEN 0
        ELSE ROUND(COUNT(DISTINCT CASE WHEN con2020.year = 2020 AND 
              con2020.color IN ('PRETA', 'PARDA', 'INDIGENA') THEN con2020.id END)::numeric / 
              COUNT(DISTINCT CASE WHEN con2020.year = 2020 THEN con2020.id END) * 100, 5)
    END AS with_quotas_concessions_percent_2020

FROM census.city c
LEFT JOIN prouni.concession con2010 ON c.id = con2010.city_id AND con2010.year = 2010
LEFT JOIN prouni.concession con2020 ON c.id = con2020.city_id AND con2020.year = 2020
GROUP BY c.id, c.ibge_code, c.federative_unit, c.name, c.is_metropolitan
ORDER BY c.federative_unit, c.name;
