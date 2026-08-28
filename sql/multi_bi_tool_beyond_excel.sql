-- Can multi-tools for business intelligence help with the salary barrier?
-- Yes
SELECT
busint,
count (resp_id)
FROM busint
WHERE busint in ("MS Power BI", "Tableau", "MS Excel", "Python custom tools")
GROUP BY busint;

/**
busint	count (resp_id)
MS Excel	327
MS Power BI	285
Python custom tools	35
Tableau	102
**/

-- count pairs with Excel
-- one-hot encoding per respondent as respondent_profiles
-- group by identified tools as tool_groups
-- join tool_groups to df_single_with_grps to access salary_broader field

WITH respondent_profiles AS (
    SELECT 
        resp_id,
        MAX(CASE WHEN busint = 'MS Excel' THEN 1 ELSE 0 END) AS has_excel,
        MAX(CASE WHEN busint = 'MS Power BI' THEN 1 ELSE 0 END) AS has_power_bi,
        MAX(CASE WHEN busint = 'Tableau' THEN 1 ELSE 0 END) AS has_tableau,
        MAX(CASE WHEN busint LIKE '%Python%' THEN 1 ELSE 0 END) AS has_python,
        COUNT(DISTINCT CASE WHEN busint NOT IN ('Not Applicable', 'None of the above') 
                            THEN busint END) AS total_tools
    FROM busint
    GROUP BY resp_id
),
tool_groups AS (
    SELECT 
        resp_id,
        CASE 
            WHEN has_excel = 1 AND has_power_bi = 0 AND has_tableau = 0 AND has_python = 0 AND total_tools = 1 
                THEN 'excel_only'
            WHEN has_excel = 1 AND has_power_bi = 1 AND has_tableau = 0 AND has_python = 0
                THEN 'excel_and_power_bi'
            WHEN has_excel = 1 AND has_tableau = 1 
                THEN 'excel_and_tableau'
            WHEN has_excel = 1 AND has_python = 1 
                THEN 'excel_and_python'
            ELSE NULL 
        END AS tool_fluency_group
    FROM respondent_profiles
)

-- 1. Main Percentage Matrix
SELECT 
    s.salary_broader,
    ROUND(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_only' THEN 1 END) * 100.0 / SUM(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_only' THEN 1 END)) OVER(), 1) AS excel_only,
    ROUND(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_power_bi' THEN 1 END) * 100.0 / SUM(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_power_bi' THEN 1 END)) OVER(), 1) AS excel_and_power_bi,
    ROUND(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_tableau' THEN 1 END) * 100.0 / SUM(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_tableau' THEN 1 END)) OVER(), 1) AS excel_and_tableau,
    ROUND(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_python' THEN 1 END) * 100.0 / SUM(COUNT(CASE WHEN tg.tool_fluency_group = 'excel_and_python' THEN 1 END)) OVER(), 1) AS excel_and_python,
    CASE s.salary_broader
        WHEN '35k and less' THEN 1
        WHEN '35k+ to 75k' THEN 2
        WHEN '75k+ to 100k' THEN 3
        WHEN '100k and above' THEN 4
    END AS sort_order
FROM tool_groups tg
JOIN df_single_with_grps s ON tg.resp_id = s.resp_id
WHERE tg.tool_fluency_group IS NOT NULL
  AND s.salary_broader <> 'Not Applicable'
GROUP BY s.salary_broader

UNION ALL

-- 2. Appended Total Sample Size (N) Row
SELECT 
    'TOTAL COUNT (N)' AS salary_broader,
    COUNT(CASE WHEN tool_fluency_group = 'excel_only' THEN 1 END) AS excel_only,
    COUNT(CASE WHEN tool_fluency_group = 'excel_and_power_bi' THEN 1 END) AS excel_and_power_bi,
    COUNT(CASE WHEN tool_fluency_group = 'excel_and_tableau' THEN 1 END) AS excel_and_tableau,
    COUNT(CASE WHEN tool_fluency_group = 'excel_and_python' THEN 1 END) AS excel_and_python,
    5 AS sort_order -- Forces this row to the absolute bottom
FROM tool_groups tg
JOIN df_single_with_grps s ON tg.resp_id = s.resp_id
WHERE tg.tool_fluency_group IS NOT NULL 
  AND s.salary_broader <> 'Not Applicable'

ORDER BY sort_order ASC;

/**
salary_broader	excel_only	excel_and_power_bi	excel_and_tableau	excel_and_python	sort_order
35k and less	70.5	35.0	25.0	37.5	1
35k+ to 75k	25.9	48.9	35.7	37.5	2
75k+ to 100k	1.8	6.6	10.7	0.0	3
100k and above	1.8	9.5	28.6	25.0	4
TOTAL COUNT (N)	112	137	56	8	5
**/
