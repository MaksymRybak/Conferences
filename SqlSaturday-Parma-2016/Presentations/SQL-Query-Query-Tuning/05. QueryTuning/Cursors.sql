--
-- Cursori
--

USE AdventureWorks2014;
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON

-- The running total
CREATE TABLE #Customers_Totals (CustomerID INT NOT NULL, [Year] INT NOT NULL, [Month] INT NOT NULL, Month_Total INT, Total_YTD INT)
GO

DECLARE	@CustomerID INT,
		@Year		INT,
		@Month		INT,
		@Month_Total INT,
		@Running_Total INT = 0,
		@Current_Year INT;

DECLARE  Running_Sum CURSOR
FOR
SELECT	CustomerID,
		YEAR(OrderDate)		AS [Year],
		MONTH(OrderDate)	AS [Month],
		SUM(TotalDue)		AS [Month_Total]
FROM	Sales.SalesOrderHeader
GROUP BY	CustomerID,
			YEAR(OrderDate),
			MONTH(OrderDate)
ORDER BY	CustomerID,
			[Year],
			[Month];

OPEN Running_Sum;

FETCH NEXT FROM Running_Sum 
INTO	@CustomerID,
		@Year,
		@Month,
		@Month_Total

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Running_Total += @Month_Total;
	SET @Current_Year = @Year;
	INSERT INTO #Customers_Totals(CustomerID, [Year], [Month], [Month_Total], Total_YTD)
	VALUES	(	
				@CustomerID,
				@Year,
				@Month,
				@Month_Total,
				@Running_Total
			);
	FETCH NEXT FROM Running_Sum 
	INTO	@CustomerID,
			@Year,
			@Month,
			@Month_Total;
	IF	@Current_Year <> @Year
		SET @Running_Total = 0; --Reset for each year
END;

ALTER TABLE #Customers_Totals
ADD CONSTRAINT PK_Customer_Totals
PRIMARY KEY (CustomerID, [Year], [Month]);

SELECT	*
FROM	#Customers_Totals
ORDER BY CustomerID, [Year], [Month]

CLOSE	Running_Sum;
DEALLOCATE Running_Sum;

DROP TABLE #Customers_Totals
GO

-- Window functions
SELECT	*,
		SUM(Month_Total) OVER	(
								PARTITION BY	CustomerID,
												[Year]
								ORDER BY	[Year], 
											[Month]
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
								) AS Total_YTD
FROM
(
	SELECT	CustomerID,
			YEAR(OrderDate)					AS [Year],
			MONTH(OrderDate)				AS [Month],
			CAST(SUM(TotalDue) AS INT)		AS Month_Total
	FROM	Sales.SalesOrderHeader
	GROUP BY	CustomerID,
				YEAR(OrderDate),
				MONTH(OrderDate)
) AS X
ORDER BY	CustomerID,
			[Year],
			[Month];
GO

SET STATISTICS IO OFF
SET STATISTICS TIME OFF


-- End of Demo Script