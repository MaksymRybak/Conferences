--SQL Saturday 566. Parma 26 november 2016. 
--10. Expression aliases


USE AdventureWorksDW2014;
GO

--this query doesn't work

SELECT 
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	SalesAmount
FROM dbo.FactResellerSales
WHERE OrderYear = 2013

--this query works
SELECT 
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	SalesAmount
FROM dbo.FactResellerSales
WHERE OrderDate > '20121231'
ORDER BY OrderMonth

--You can alias the columns inside a subquery and then call them by alias
--this is one of many possible solutions, but keeps code simple and clean
SELECT 
	alias.OrderYear, 
	alias.OrderMonth,
	SUM(fis.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales fis
  CROSS APPLY (
	SELECT 
		YEAR(fis.OrderDate) AS OrderYear, 
		MONTH(fis.OrderDate) AS OrderMonth
	) AS alias
WHERE alias.OrderYear = 2013
GROUP BY alias.OrderYear, alias.OrderMonth
ORDER BY alias.OrderMonth DESC;


