--SQL Saturday 566. Parma 26 november 2016.  
--5. TOP 3 orders for every employee  
USE AdventureWorks2014;
GO


SELECT 
	 sp.BusinessEntityID,
	 pp.FirstName, 
	 pp.LastName,
	 hre.JobTitle,
	 CONVERT(char(10),ord.OrderDate,103) AS OrderDate,
	 SUM(ord.TotalDue) AS Amount 
FROM Sales.SalesPerson sp
	INNER JOIN Person.Person pp ON sp.BusinessEntityID = pp.BusinessEntityID
	INNER JOIN HumanResources.Employee hre ON sp.BusinessEntityID = hre.BusinessEntityID
	OUTER APPLY (
		SELECT TOP 3
			OrderDate,
			TotalDue 
		FROM Sales.SalesOrderHeader
		WHERE SalesPersonID = sp.BusinessEntityID
		ORDER BY OrderDate DESC
	) ord
GROUP BY 
	 sp.BusinessEntityID,
	 pp.FirstName, 
	 pp.LastName,
	 hre.JobTitle,
	 ord.OrderDate
ORDER BY sp.BusinessEntityID, ord.OrderDate