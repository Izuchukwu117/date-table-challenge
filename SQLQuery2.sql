/*REVAMPED SOLUTION TO DATE TABLE (By Izuchukwu Ezeugbor)*/

/*THIS IS A MUCH MORE OPTIMIZED SOLUTION TO THE DATE TABLE CHALLENGE.
THE ONLY CHALLENGE IN THIS QUERY IS THE VARIABLE EASTER AND ISLAMIC PUBLIC HOLIDAY DATES (ONE HAS
TO MANUALLY ADD CONDITIONAL QUERIES IN THE date_series CTE). APART FROM THAT, SIMPLY CHANGE START
AND END DATES IN THE VARIABLES SET BY "DECLARE" KEY WORD*/

IF OBJECT_ID(N'date_table',N'U') IS NULL --MSSQL VERSION OF "CREATE TABLE date_table IF EXISTS"
BEGIN
	CREATE TABLE date_table(
		date DATE,
		year INT,
		day_of_year INT,
		quarter VARCHAR(50),
		quarter_start_date DATE,
		quarter_end_date DATE,
		month_num INT,
		month_name TEXT,
		month_start_date DATE,
		month_end_date DATE,
		week_num_year INT,
		weekday_name TEXT,
		weekday_name_short TEXT,
		weekday_num INT,
		day_in_month INT,
		week_start_date VARCHAR(50),
		week_end_date VARCHAR(50),
		year_month VARCHAR(50),
		year_quarter VARCHAR(50),
		fiscal_year VARCHAR(50),
		fiscal_quarter VARCHAR(50),
		is_holiday VARCHAR(50),
		is_weekend VARCHAR(50)
	)
END;
TRUNCATE TABLE date_table; 
DECLARE @start_date date, @end_date date;
SET @start_date='01/01/2023'; --Just change start and end dates at any time
SET @end_date='2023/12/31';
WITH date_series AS
	(SELECT DATEADD(DAY,value,@start_date) date,
		CASE WHEN MONTH(DATEADD(DAY,value,@start_date))=1
			AND DAY(DATEADD(DAY,value,@start_date))=1 THEN 'New Years Day'
			WHEN MONTH(DATEADD(DAY,value,@start_date))=1
			AND DAY(DATEADD(DAY,value,@start_date))=2 THEN 'Day off for New Years Day'
			WHEN MONTH(DATEADD(DAY,value,@start_date))=6
			AND DAY(DATEADD(DAY,value,@start_date))=12 THEN 'Democracy Day'
			WHEN MONTH(DATEADD(DAY,value,@start_date))=10
			AND DAY(DATEADD(DAY,value,@start_date))=1 THEN 'Independence Day'
			WHEN MONTH(DATEADD(DAY,value,@start_date))=12
			AND DAY(DATEADD(DAY,value,@start_date))=25 THEN 'Christmas Day'
			WHEN MONTH(DATEADD(DAY,value,@start_date))=12
			AND DAY(DATEADD(DAY,value,@start_date))=26 THEN 'Boxing Day'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-04-09' THEN 'Easter Sunday'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-04-10' THEN 'Easter Monday'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-04-21' THEN 'Eid-el-Fitr'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-04-24' THEN 'Eid-el-Fitr Holiday'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-06-28' THEN 'Eid el Kabir'
			WHEN CAST(DATEADD(DAY,value,@start_date)AS DATE)='2023-06-29' THEN 'Eid el Kabir Holiday'
			/*<<<<<ADD MORE CONDITIONAL CLAUSES FOR VARIABLE HOLIDAY DATES FOR EASTER and ISLAMIC HOLIDAYS IN SUBSEQUENT YEARS>>>>>>
			<<<<<<<<ALL OTHER HOLIDAYS(Christmas, Independence Day, etc) ARE FIXED. NO NEED ADDING THEM AGAIN>>>>>*/
			END holidays
	FROM generate_series(0,1000000,1) --the END value (middle number) can be of any value for as long as it is greater than date range
	WHERE DATEADD(DAY,value,@start_date) <= @end_date)
INSERT INTO date_table
SELECT date,
	YEAR(date),
	DATEPART (DAYOFYEAR,date),
	CONCAT('Q',DATEPART (QUARTER, date)),
	CONCAT(YEAR(date),'-',
		CASE WHEN DATEPART (MONTH,date) IN (1,2,3) THEN 1
			WHEN DATEPART (MONTH,date) IN (4,5,6) THEN 4
			WHEN DATEPART (MONTH,date) IN (7,8,9) THEN 7
			ELSE 10 END,'-','01'),
	CONCAT(YEAR(date),'-',
		CASE WHEN MONTH(date) IN (1,2,3) THEN 3
			WHEN MONTH(date) IN (4,5,6) THEN 6
			WHEN MONTH(date) IN (7,8,9) THEN 9
			ELSE 12 END,'-',
		CASE WHEN MONTH(date) IN (4,5,6,7,8,9) THEN 30
			ELSE 31 END),
	MONTH(date),
	DATENAME (MONTH,date),
	CONCAT(YEAR(date),'-',MONTH(date),'-','01'),
	CONCAT(YEAR(date),'-',MONTH(date),'-',MAX(DAY(date)) OVER (PARTITION BY YEAR(date),MONTH(date))),
	DATEPART (WEEK,date),
	DATENAME (WEEKDAY,date),
	LEFT(DATENAME (WEEKDAY,date),3),
	DATEPART (WEEKDAY,date),
	DATEPART (DAY,date),
	CONCAT(LEFT(DATENAME(WEEKDAY,MIN (date) OVER(PARTITION BY DATEPART (WEEK,date))),3),
		'-',
		LEFT(DATENAME (MONTH,date),3),RIGHT(YEAR(date),2)),
	CONCAT(LEFT(DATENAME(WEEKDAY,MAX (date) OVER(PARTITION BY DATEPART (WEEK,date))),3),
		'-',
		LEFT(DATENAME (MONTH,date),3),RIGHT(YEAR(date),2)),
	CONCAT(YEAR(date),'-',LEFT(DATENAME (MONTH,date),3)),
	CONCAT(YEAR(date),'-',CONCAT('Q',DATEPART (QUARTER, date))),
	CASE WHEN DATEPART (MONTH,date)<7 THEN CONCAT ('FY',YEAR(date)-1)
		ELSE CONCAT('FY',YEAR(date)) END,
	CASE WHEN DATENAME (MONTH,date) IN ('January','February','March') THEN 'FY-Q3'
		WHEN DATENAME (MONTH,date) IN ('April','May','June') THEN 'FY-Q4'
		WHEN DATENAME (MONTH,date) IN ('July','August','September') THEN 'FY-Q1'
		ELSE 'FY-Q2' END,
	CASE WHEN holidays IS NULL THEN 'FALSE'
		ELSE 'TRUE' END,
	CASE WHEN DATENAME (WEEKDAY,date) IN ('Saturday','Sunday') THEN 'TRUE'
		ELSE 'FALSE' END
FROM date_series;
SELECT * FROM date_table
ORDER BY date;
