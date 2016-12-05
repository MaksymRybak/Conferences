--SQL Saturday 566. Parma 26 november 2016. 
--9. OFFSET - FETCH
USE AdventureWorksDW2014;
GO

--skip first 10 rows from the sorted result and return next five rows 
SELECT 
	FirstName + ', ' + LastName As Employee
FROM dbo.DimEmployee
ORDER BY FirstName
OFFSET 10 ROWSFETCH NEXT 5 ROWS ONLY;

--use OFFSET - FETCH to retrieve the last two orders for every customer. Alternative to TOP
SELECT 
	c.FirstName,
	c.LastName,
	IntSales.OrderDate,
	IntSales.ProductName,
	IntSales.SalesAmount
FROM dbo.DimCustomer c
OUTER APPLY 
--note you don't need to create a function. Can use the APPLY operator directly with a SELECT
	(SELECT 
		fis.OrderDate,
		fis.ProductKey,
		dp.EnglishProductName AS ProductName,
		fis.CustomerKey
		SalesAmount
	FROM dbo.FactInternetSales fis
		INNER JOIN dbo.DimProduct dp ON fis.ProductKey = dp.ProductKey
	WHERE fis.CustomerKey = c.CustomerKey
	ORDER BY fis.CustomerKey, fis.OrderDate DESC
	OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY
	) IntSales
;


--now we want to calculate the total number of records in the resultset filtered by OFFSET FETCH.
USE AdventureWorks2014;
GO
DECLARE @PageSize int = 10,
        @PageNum  int = 1;

SELECT
[SalesOrderID]
, [SalesOrderDetailID]
, [CarrierTrackingNumber]
, [OrderQty]
, [ProductID]
, [SpecialOfferID]
, [TotalCount]
FROM Sales.SalesOrderDetail
	CROSS APPLY (
		SELECT COUNT(*) AS TotalCount
		FROM Sales.SalesOrderDetail 
	) [Count]
ORDER BY SalesOrderID
OFFSET (@PageNum-1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY
GO

