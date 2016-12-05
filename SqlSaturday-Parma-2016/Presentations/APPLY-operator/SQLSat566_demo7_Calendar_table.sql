--SQL Saturday 566. Parma 26 november 2016. 
--6. Date ranges. CROSS JOIN vs CROSS APPLY

USE Test;
GO

--create a tally table with calendar
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vTally')
DROP VIEW dbo.vTally;
GO 
 
CREATE VIEW [dbo].[vTally]
AS
WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Tally AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT TOP (100000000) N FROM Tally ORDER BY N 
;
GO 

--create a calendar table for year 2016
IF EXISTS (SELECT * FROM sys.tables WHERE name like 'CalendarTable')
DROP TABLE dbo.CalendarTable;
GO

;WITH Dates (N, CalendarDate) AS (
	SELECT TOP(366) 
		N, DATEADD(DAY,N-1, CONVERT(DATE,'1/1/2016')) 
	FROM vTally
)
SELECT 
	N as DateID, 
	CalendarDate
	,DATEPART(day,CalendarDate) as CDay
	,DATEPART(month,CalendarDate) as MonthNo
	,DATEPART(year,CalendarDate) as YearNo
	,DATEPART(DW,CalendarDate) as [DayofWeek]
	,DATENAME(WEEKDAY,CalendarDate) AS WeekDay
	,CASE WHEN EOMONTH(CalendarDate) = CalendarDate 
			THEN 1
			ELSE 0
	END as EndOfMonth
	,CASE WHEN DATEPART(DW,CalendarDate) IN (1,7)
			THEN 1
			ELSE 0
	END as Weekend
INTO dbo.CalendarTable
FROM Dates;

CREATE NONCLUSTERED INDEX idx_CalDate ON dbo.CalendarTable(CalendarDate) INCLUDE (WeekDay);

SELECT * FROM dbo.CalendarTable;

--Attendance data for Employees are on rows, with only start and end date
--We want to list every day for every employee
SELECT * FROM dbo.Attendance WHERE UserName = N'10001'

--with CROSS JOIN against the tally table 
SELECT 
	UserName,
	SessionStartDate, 
	SessionEndDate ,
	cal.CalendarDate,
	cal.WeekDay
FROM dbo.Attendance at
CROSS JOIN dbo.CalendarTable cal 
WHERE UserName = '10001'
	AND cal.CalendarDate >= at.SessionStartDate
	AND cal.CalendarDate <= at.SessionEndDate 
ORDER BY cal.CalendarDate;

--with CROSS APPLY. No need for a function. Directly inside the query
SELECT 
	UserName,
	SessionStartDate, 
	SessionEndDate ,
	cal.CalendarDate,
	cal.WeekDay
FROM dbo.Attendance at
	CROSS APPLY (
		SELECT 
			CalendarDate, WeekDay
		FROM dbo.CalendarTable
		WHERE CalendarDate >= at.SessionStartDate 
			AND CalendarDate <= at.SessionEndDate
	) cal 
WHERE at.UserName = '10001'
ORDER BY UserName, cal.CalendarDate;
