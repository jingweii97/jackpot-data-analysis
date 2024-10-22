DECLARE @middle INT = 27;

WITH temp_1 as
(
	SELECT *, ROW_NUMBER() OVER(ORDER BY DrawDate) as row_num
	FROM [Power_Toto].[dbo].PowerTotoHistoricalData
),
temp_table as
(SELECT DrawNo,row_num,
	SUM(CASE WHEN DrawnNo1 % 2 = 0 AND DrawnNo1 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo2 % 2 = 0 AND DrawnNo2 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo3 % 2 = 0 AND DrawnNo3 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo4 % 2 = 0 AND DrawnNo4 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo5 % 2 = 0 AND DrawnNo5 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo6 % 2 = 0 AND DrawnNo6 >@middle THEN 1 ELSE 0 END ) AS even_high_count,
	SUM(CASE WHEN DrawnNo1 % 2 <> 0 AND DrawnNo1 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo2 % 2 <> 0 AND DrawnNo2 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo3 % 2 <> 0 AND DrawnNo3 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo4 % 2 <> 0 AND DrawnNo4 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo5 % 2 <> 0 AND DrawnNo5 >@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo6 % 2 <> 0 AND DrawnNo6 >@middle THEN 1 ELSE 0 END) AS odd_high_count,
	SUM(CASE WHEN DrawnNo1 % 2 = 0 AND DrawnNo1 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo2 % 2 = 0 AND DrawnNo2 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo3 % 2 = 0 AND DrawnNo3 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo4 % 2 = 0 AND DrawnNo4 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo5 % 2 = 0 AND DrawnNo5 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo6 % 2 = 0 AND DrawnNo6 <=@middle THEN 1 ELSE 0 END ) AS even_low_count,
	SUM(CASE WHEN DrawnNo1 % 2 <> 0 AND DrawnNo1 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo2 % 2 <> 0 AND DrawnNo2 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo3 % 2 <> 0 AND DrawnNo3 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo4 % 2 <> 0 AND DrawnNo4 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo5 % 2 <> 0 AND DrawnNo5 <=@middle THEN 1 ELSE 0 END +
		CASE WHEN DrawnNo6 % 2 <> 0 AND DrawnNo6 <=@middle THEN 1 ELSE 0 END) AS odd_low_count
FROM 
	temp_1
	GROUP BY DrawNo, row_num),
CombinationCounts AS
(
	SELECT even_high_count,odd_high_count,even_low_count,odd_low_count, COUNT(*) AS Combination_Count FROM temp_table
	GROUP BY even_high_count,odd_high_count,even_low_count,odd_low_count
),
CombinationProbability AS
(
	SELECT *,Combination_Count*100.00 / (SELECT SUM(Combination_Count) FROM CombinationCounts) as Occurence  
	FROM CombinationCounts
),
UnwantedProbability AS
(
	SELECT t.row_num 
	FROM temp_table as t INNER JOIN (SELECT * FROM CombinationProbability WHERE Occurence < 4) as c
	ON t.even_high_count = c.even_high_count AND t.even_low_count = c.even_low_count AND
	t.odd_high_count = c.odd_high_count AND t.odd_low_count = c.odd_low_count
),
UnwantedRowNum AS
(
	SELECT t.DrawDate,t.DrawnNo1,t.DrawnNo2,t.DrawnNo3,t.DrawnNo4,t.DrawnNo5,t.DrawnNo6,t.row_num , isDesiredCombination = 'N' FROM temp_1 as t INNER JOIN UnwantedProbability as u
	ON t.row_num = u.row_num
)

SELECT t.DrawDate,t.DrawnNo1,t.DrawnNo2,t.DrawnNo3,t.DrawnNo4,t.DrawnNo5,t.DrawnNo6,t.row_num, COALESCE(u.isDesiredCombination,'Y') isDesiredCombination
FROM temp_1 as t LEFT JOIN UnwantedRowNum as u ON t.DrawDate = u.DrawDate
ORDER BY t.DrawDate DESC

--,
--RepeatedNumbers AS
--(
--	    SELECT t1.DrawDate,t1.DrawnNo1,t1.DrawnNo2,t1.DrawnNo3,t1.DrawnNo4,t1.DrawnNo5,t1.DrawnNo6,
--        t1.row_num AS current_row_num,
--        t2.row_num AS next_row_num,
--		CASE WHEN t1.row_num = t2.row_num -1 THEN 1 ELSE 0 END 
--			AS is_next_increment
--    FROM 
--        UnwantedRowNum t1
--    INNER JOIN 
--        UnwantedRowNum t2 ON t1.id = t2.id - 1
--)

--SELECT * FROM RepeatedNumbers ORDER BY DrawDate DESC

/*

,
DataWithGroups AS
(
    SELECT 
        current_row_num,
        next_row_num,
        is_next_increment,
        ROW_NUMBER() OVER (ORDER BY current_row_num) - 
        ROW_NUMBER() OVER (PARTITION BY is_next_increment ORDER BY current_row_num) AS group_id
    FROM 
        RepeatedNumbers  -- Replace with your actual table name
),
SequenceLengths AS
(
    SELECT 
        group_id,
        COUNT(*) AS sequence_length,
        MIN(current_row_num) AS start_row,
        MAX(next_row_num) AS end_row
    FROM 
        DataWithGroups
    WHERE 
        is_next_increment = 1
    GROUP BY 
        group_id
)
SELECT 
    sequence_length,
    start_row,
    end_row
FROM 
    SequenceLengths
ORDER BY 
    start_row;

*/


--SELECT * FROM CombinationProbability ORDER BY Occurence DESC;

