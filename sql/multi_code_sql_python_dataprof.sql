-- Can SQL and Python help with crossing the 100k salary barrier?
-- Among Data Professionals Only

SELECT w.whatused,
count(*)
FROM whatused w
JOIN df_single_with_grps df
ON w.resp_id = df.resp_id
WHERE df.careerstg = "Professional - employed full-time in a data-related role"
GROUP BY whatused
;
/**
whatused	count(*)
Appscript	12
Bash Script	30
C	8
C#	21
C++	16
DAX	65
Dart	1
Golang	5
HTML	37
Java	20
Javascript	48
Lookml	4
M language	44
MATLAB	8
None of the above	49
PHP	19
Perl	3
Python	189
R	18
Ruby	1
SAS	6
SQL	224
Scala	5
Typescript	15
VB.net	6
VBA	41
**/


-- Step 1
DROP VIEW IF EXISTS prof_respondent_tool_flags_view;

CREATE VIEW prof_respondent_tool_flags_view AS
SELECT 
    s.resp_id,
    s.salary_broader,
    -- Check Excel independently from subquery
    COALESCE((
        SELECT 1 FROM generaltools g 
        WHERE g.resp_id = s.resp_id AND g.generaltools = 'Microsoft Excel' 
        LIMIT 1
    ), 0) AS has_excel,
    -- Check SQL independently from subquery
    COALESCE((
        SELECT 1 FROM whatused w 
        WHERE w.resp_id = s.resp_id AND w.whatused = 'SQL' 
        LIMIT 1
    ), 0) AS has_sql,
    -- Check Python independently from subquery
    COALESCE((
        SELECT 1 FROM whatused w 
        WHERE w.resp_id = s.resp_id AND w.whatused = 'Python' 
        LIMIT 1
    ), 0) AS has_python
FROM df_single_with_grps s
WHERE s.salary_broader <> 'Not Applicable'
AND s.careerstg = "Professional - employed full-time in a data-related role" ;

SELECT * FROM prof_respondent_tool_flags_view LIMIT 10;

/**
resp_id	salary_broader	has_excel	has_sql	has_python
2	35k and less	1	0	0
3	100k and above	1	1	1
5	100k and above	1	1	1
6	100k and above	0	1	0
8	35k and less	0	0	1
10	100k and above	1	1	1
13	35k+ to 75k	1	1	1
16	100k and above	1	1	1
17	100k and above	0	1	1
19	35k+ to 75k	0	1	1

**/

-- Step 2
DROP VIEW IF EXISTS prof_respondent_mutually_exclusive_groups_view;

CREATE VIEW prof_respondent_mutually_exclusive_groups_view AS
SELECT 
    resp_id,
    salary_broader,
    CASE 
        WHEN has_excel = 1 AND has_sql = 0 AND has_python = 0 THEN 'excel_only'
        WHEN has_excel = 1 AND has_sql = 1 AND has_python = 0 THEN 'excel_and_sql_no_python'
        WHEN has_excel = 1 AND has_python = 1 AND has_sql = 0 THEN 'excel_and_python_no_sql'
        WHEN has_excel = 1 AND has_sql = 1 AND has_python = 1 THEN 'all_three'
        ELSE 'other_combinations'
    END AS tool_combination
FROM prof_respondent_tool_flags_view;


SELECT * FROM prof_respondent_mutually_exclusive_groups_view LIMIT 10;

/**
resp_id	salary_broader	tool_combination
2	35k and less	excel_only
3	100k and above	all_three
5	100k and above	all_three
6	100k and above	other_combinations
8	35k and less	other_combinations
10	100k and above	all_three
13	35k+ to 75k	all_three
16	100k and above	all_three
17	100k and above	other_combinations
19	35k+ to 75k	other_combinations

**/

-- This query takes a few seconds 
SELECT 
salary_broader,
tool_combination,
count(*)
FROM prof_respondent_mutually_exclusive_groups_view
GROUP BY  salary_broader, tool_combination
ORDER BY salary_broader, tool_combination;

/**
salary_broader	tool_combination	count(*)
100k and above	all_three	29
100k and above	excel_and_python_no_sql	5
100k and above	excel_and_sql_no_python	12
100k and above	excel_only	5
100k and above	other_combinations	27
35k and less	all_three	21
35k and less	excel_and_python_no_sql	11
35k and less	excel_and_sql_no_python	21
35k and less	excel_only	28
35k and less	other_combinations	32
35k+ to 75k	all_three	31
35k+ to 75k	excel_and_python_no_sql	13
35k+ to 75k	excel_and_sql_no_python	23
35k+ to 75k	excel_only	35
35k+ to 75k	other_combinations	38
75k+ to 100k	all_three	6
75k+ to 100k	excel_and_python_no_sql	4
75k+ to 100k	excel_and_sql_no_python	7
75k+ to 100k	excel_only	1
75k+ to 100k	other_combinations	15
**/


-- Step 3: Check matrix
SELECT 
    salary_broader,
    SUM(CASE WHEN tool_combination = 'excel_only' THEN cnt ELSE 0 END) AS excel_only,
    SUM(CASE WHEN tool_combination = 'excel_and_sql_no_python' THEN cnt ELSE 0 END) AS excel_sql,
    SUM(CASE WHEN tool_combination = 'excel_and_python_no_sql' THEN cnt ELSE 0 END) AS excel_python,
    SUM(CASE WHEN tool_combination = 'all_three' THEN cnt ELSE 0 END) AS all_three,
    SUM(CASE WHEN tool_combination = 'other_mixtures' OR tool_combination = 'other_combinations' THEN cnt ELSE 0 END) AS other_combinations
FROM (
    -- Above query output table mapped as source rows
    SELECT 
        tool_combination,
        salary_broader,
        COUNT(*) AS cnt
    FROM prof_respondent_mutually_exclusive_groups_view
    GROUP BY tool_combination, salary_broader
) sub
GROUP BY salary_broader
ORDER BY 
    CASE salary_broader
        WHEN '35k and less' THEN 1
        WHEN '35k+ to 75k' THEN 2
        WHEN '75k+ to 100k' THEN 3
        WHEN '100k and above' THEN 4
    END;

/**
salary_broader	excel_only	excel_sql	excel_python	all_three	other_combinations
35k and less	28	21	11	21	32
35k+ to 75k	35	23	13	31	38
75k+ to 100k	1	7	4	6	15
100k and above	5	12	5	29	27
**/
	
--Step 4: Create a prof_pivoted_salary_tools_view
DROP VIEW IF EXISTS prof_pivoted_salary_tools_view;

CREATE VIEW prof_pivoted_salary_tools_view AS
SELECT 
    salary_broader,
    SUM(CASE WHEN tool_combination = 'excel_only' THEN cnt ELSE 0 END) AS excel_only,
    SUM(CASE WHEN tool_combination = 'excel_and_sql_no_python' THEN cnt ELSE 0 END) AS excel_sql,
    SUM(CASE WHEN tool_combination = 'excel_and_python_no_sql' THEN cnt ELSE 0 END) AS excel_python,
    SUM(CASE WHEN tool_combination = 'all_three' THEN cnt ELSE 0 END) AS all_three,
    SUM(CASE WHEN tool_combination IN ('other_mixtures', 'other_combinations') THEN cnt ELSE 0 END) AS other_combinations,
    CASE salary_broader
        WHEN '35k and less' THEN 1
        WHEN '35k+ to 75k' THEN 2
        WHEN '75k+ to 100k' THEN 3
        WHEN '100k and above' THEN 4
    END AS sort_order
FROM (
    SELECT 
        tool_combination,
        salary_broader,
        COUNT(*) AS cnt
    FROM prof_respondent_mutually_exclusive_groups_view
    GROUP BY tool_combination, salary_broader
) sub
GROUP BY salary_broader;

-- This takes a few seconds
SELECT * FROM prof_pivoted_salary_tools_view;

/**
salary_broader	excel_only	excel_sql	excel_python	all_three	other_combinations	sort_order
100k and above	5	12	5	29	27	4
35k and less	28	21	11	21	32	1
35k+ to 75k	35	23	13	31	38	2
75k+ to 100k	1	7	4	6	15	3
**/


-- Step 5: Add the Total N row and convert to percentages
-- Takes 12 or more seconds

-- 1. Main Percentage Matrix Rows
SELECT 
    salary_broader,
    ROUND(excel_only * 100.0 / SUM(excel_only) OVER(), 1) AS excel_only,
    ROUND(excel_sql * 100.0 / SUM(excel_sql) OVER(), 1) AS excel_sql,
    ROUND(excel_python * 100.0 / SUM(excel_python) OVER(), 1) AS excel_python,
    ROUND(all_three * 100.0 / SUM(all_three) OVER(), 1) AS all_three,
    ROUND(other_combinations * 100.0 / SUM(other_combinations) OVER(), 1) AS other_combinations,
    sort_order 
FROM prof_pivoted_salary_tools_view

UNION ALL

-- 2. Appended Total Column Sizes (N)
SELECT 
    'TOTAL COUNT (N)' AS salary_broader,
    SUM(excel_only) AS excel_only,
    SUM(excel_sql) AS excel_sql,
    SUM(excel_python) AS excel_python,
    SUM(all_three) AS all_three,
    SUM(other_combinations) AS other_combinations,
    5 AS sort_order
FROM prof_pivoted_salary_tools_view

ORDER BY sort_order ASC;

/**
salary_broader	excel_only	excel_sql	excel_python	all_three	other_combinations	sort_order
35k and less	40.6	33.3	33.3	24.1	28.6	1
35k+ to 75k	50.7	36.5	39.4	35.6	33.9	2
75k+ to 100k	1.4	11.1	12.1	6.9	13.4	3
100k and above	7.2	19.0	15.2	33.3	24.1	4
TOTAL COUNT (N)	69	63	33	87	112	5

**/
