WITH temp as
(
	SELECT *, ROW_NUMBER() OVER(ORDER BY DrawDate) as row_num
	FROM [Power_Toto].[dbo].PowerTotoHistoricalData
),RepeatedNumbers AS
(
	    SELECT 
        t1.row_num AS current_row_num,
        t2.row_num AS next_row_num,
		(CASE WHEN t1.DrawnNo1 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END + 
        CASE WHEN t1.DrawnNo2 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END + 
        CASE WHEN t1.DrawnNo3 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END + 
        CASE WHEN t1.DrawnNo4 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END + 
        CASE WHEN t1.DrawnNo5 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END + 
        CASE WHEN t1.DrawnNo6 IN (t2.DrawnNo1, t2.DrawnNo2, t2.DrawnNo3, t2.DrawnNo4, t2.DrawnNo5, t2.DrawnNo6) THEN 1 ELSE 0 END)
			AS repeated_count
    FROM 
        temp t1
    INNER JOIN 
        temp t2 ON t1.row_num = t2.row_num - 1
)

SELECT repeated_count, COUNT(*)*1.0/(SELECT COUNT(*) FROM RepeatedNumbers) AS repeated_percentage FROM RepeatedNumbers
GROUP BY repeated_count
ORDER BY repeated_count

SELECT *, ROW_NUMBER() OVER(ORDER BY DrawDate) as row_num
FROM [Power_Toto].[dbo].PowerTotoHistoricalData






