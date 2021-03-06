--
-- SARGability
--

USE AdventureWorks2014
GO

--
-- Setup
--
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('Production.Product') AND name = 'IX_SellStartDate')
CREATE INDEX IX_SellStartDate ON Production.Product(SellStartDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('Production.Product') AND name = 'IX_ProductLine')
CREATE INDEX IX_ProductLine ON Production.Product(ProductLine);


-- NON SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE YEAR(SellStartDate) = 2011

-- SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE SellStartDate >= '2011-01-01 00:00:00.000'
	AND SellStartDate < '2012-01-01 00:00:00.000'



-- NON SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE ISNULL(ProductLine,'M') = 'M'

-- SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE ProductLine = 'M' OR ProductLine IS NULL



-- NON SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE LEFT(ProductNumber,2) = 'BK'

-- SARGable
SELECT COUNT(*)
FROM Production.Product
WHERE ProductNumber LIKE 'BK%'
