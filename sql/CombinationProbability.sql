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
)

SELECT *,Combination_Count*100.00 / (SELECT SUM(Combination_Count) FROM CombinationCounts) as Occurence  
FROM CombinationCounts
ORDER BY Occurence DESC



--INSERT INTO HistoricalData_Analysis (DrawNo, Even_High_Count, Odd_High_Count, Even_Low_Count, Odd_Low_Count)
--SELECT DrawNo, even_high_count, odd_high_count, even_low_count, odd_low_count FROM temp_table;