--SQL Saturday 566. Parma 26 november 2016. 
--Demo are based on sample db AdventureWorks2014. 
--1. Calculate age and seniority for every employee. 
USE AdventureWorks2014;
GO

--Simple query to calculate age and seniority
SELECT
	DATEDIFF(mm,BirthDate,CURRENT_TIMESTAMP)/12.0 AS EmployeeAge,
	DATEDIFF(mm,HireDate,CURRENT_TIMESTAMP)/12.0  AS EmployeeSeniority
FROM HumanResources.Employee;
GO

--You had to write the query every time you want to make calculation and for every table. 
--Why don't use a function that you can reuse everytime you need?

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_CalculateTime') AND type = 'IF')
DROP FUNCTION dbo.ufn_CalculateTime;
GO
/*****************************************************************************
inline-TVF to calculate time periods in years, months based on an input date
******************************************************************************/
CREATE FUNCTION dbo.ufn_CalculateTime (@InputDate date)
RETURNS TABLE
AS 
RETURN
SELECT CAST(DATEDIFF(mm,@InputDate,CURRENT_TIMESTAMP)/12 AS nvarchar(3)) + N'y ' 
	+ CAST(DATEDIFF(mm,@InputDate,CURRENT_TIMESTAMP) % 12 AS nvarchar(2)) + N'm' AS YearMonth
GO

--Let's try the function passing a single date
DECLARE @InputDate date = '20000101';
SELECT * FROM dbo.ufn_CalculateTime(@InputDate);
GO

--Now apply the function to a table to calculate age and seniority of employees
SELECT 
	LoginID
	, BirthDate
	, CalcAge.YearMonth AS Age
	--, HireDate
	--, CalcSen.YearMonth AS Seniority
FROM HumanResources.Employee 
CROSS APPLY dbo.ufn_CalculateTime(BirthDate) AS CalcAge
--CROSS APPLY dbo.ufn_CalculateTime(HireDate) AS CalcSen
;
GO


--Calculate the average period of stay for employees in departments
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_CalculateAvgDpt') AND type = 'IF')
DROP FUNCTION dbo.ufn_CalculateAvgDpt;
GO
/*****************************************************************************
inline-TVF to calculate avg period in months based on two input dates
******************************************************************************/
CREATE FUNCTION dbo.ufn_CalculateAvgDpt (@StartDate date, @EndDate date)
RETURNS TABLE
AS 
RETURN
SELECT CAST(DATEDIFF(mm,@StartDate,@EndDate)/12 AS nvarchar(3)) + N'y ' + CAST(DATEDIFF(mm,@StartDate,@EndDate) % 12 AS nvarchar(2)) + N'm' AS YearMonth
GO


--Example of function calling. Average period of stay for Employees in a department
SELECT 
	COUNT(DISTINCT e.LoginID) AS EmployeeChanged
	, MAX(AvgDpt.YearMonth)  AS AvgDepartments 
FROM HumanResources.EmployeeDepartmentHistory edh 
	INNER JOIN HumanResources.Employee e ON edh.BusinessEntityID = e.BusinessEntityID
	CROSS APPLY dbo.ufn_CalculateAvgDpt(edh.StartDate, edh.EndDate) AvgDpt
WHERE edh.EndDate IS NOT NULL;

