--SQL Saturday 566. Parma 26 november 2016. 
--4. APPLY to browse hiearchical structures

USE AdventureWorksDW2014;
GO
  
--on table DimEmployee there is a parent relationship between EmployeeKey and ParentEmployeeKey
--recursive CTE to get employees hierarchy
DECLARE @LoginID AS nvarchar(30) = N'adventure-works\sandra0';
--SET @LoginID AS nvarchar(30) = N'adventure-works\jossef0';
--SET @LoginID AS nvarchar(30) = N'adventure-works\kendall0';

WITH empCTE AS (
	--anchor member
	SELECT EmployeeKey, ParentEmployeeKey, FirstName, LastName, Title 
	FROM dbo.DimEmployee
	WHERE LoginID = @LoginID
		AND EndDate IS NULL --only active employees

	UNION ALL

	--recursive member
	SELECT e.EmployeeKey, e.ParentEmployeeKey, e.FirstName, e.LastName, e.Title
	FROM empCTE c
		INNER JOIN dbo.DimEmployee e ON c.ParentEmployeeKey = e.EmployeeKey 
	--WHERE e.EmployeeKey <> e.ParentEmployeeKey
	WHERE e.EmployeeKey IS NOT NULL
)
SELECT EmployeeKey, ParentEmployeeKey,FirstName, LastName, Title
FROM empCTE;

--using recursion performances could be an issue. Furthermore you can find hierarchy for only one employee at time.  
--Let's try to have recursion using a function with CROSS APPLY

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_GetEmpHierarchy') AND type = 'TF')
DROP FUNCTION dbo.ufn_GetEmpHierarchy;
GO

CREATE FUNCTION dbo.ufn_GetEmpHierarchy(@emplID int)
RETURNS @tbl TABLE (empID int, mgrID int, FirstName nvarchar(50) , LastName nvarchar(50), Title nvarchar(50))
BEGIN
	INSERT INTO @tbl (empID, mgrID, FirstName, LastName, Title)
	SELECT e.EmployeeKey, e.ParentEmployeeKey, e.FirstName, e.LastName, e.Title
	FROM dbo.DimEmployee e
	WHERE e.EmployeeKey = @emplID
	
	INSERT INTO @tbl (empID, mgrID, FirstName, LastName, Title)
	SELECT f.empID, f.mgrID, f.FirstName, f.LastName, f.Title
	FROM @tbl t 
		CROSS APPLY dbo.ufn_GetEmpHierarchy(t.mgrID) f

	RETURN
END;
GO


--Try the function
SELECT empID, FirstName, LastName, Title FROM dbo.ufn_GetEmpHierarchy(125);

--APPLY the function to the Employee table. You can have the full hierarchy for every employee
SELECT 
	dim.FirstName + ' ' + dim.LastName AS Employee,
	f.FirstName + ' ' + f.LastName AS Hierarchy,
	f.Title,
	ROW_NUMBER () OVER (PARTITION BY dim.EmployeeKey ORDER BY dim.EmployeeKey) AS HierarchyLevel
FROM dbo.DimEmployee dim 
	CROSS APPLY dbo.ufn_GetEmpHierarchy(dim.EmployeeKey) f
;