--SQL Saturday 566. Parma 26 november 2016. 
--12. MEDIAN

USE AdventureWorksDW2014;
GO

-- Median calculation example from Dwain Camps
;WITH Counts AS
(
	--partition SalesTerritory depending on rows number, even or odd.  
   SELECT SalesTerritoryKey, c
   FROM
   (
      SELECT 
		SalesTerritoryKey, 
		c1 = (c+1)/2, 
        c2 = CASE c%2 WHEN 0 THEN 1+c/2 ELSE 0 END
      FROM
      (
        SELECT SalesTerritoryKey, c=COUNT(*)
        FROM dbo.FactResellerSales
        GROUP BY SalesTerritoryKey
      ) a
   ) a
   --using CROSS APPLY to unpivot values
   CROSS APPLY (VALUES(c1),(c2)) b(c)
)
SELECT 
	a.SalesTerritoryKey, 
	s.SalesTerritoryRegion,
	Median=AVG(0.+b.SalesAmount)
FROM
(
   SELECT 
	a.SalesTerritoryKey,
	SalesAmount, 
	ROW_NUMBER() OVER (PARTITION BY SalesTerritoryKey ORDER BY SalesAmount) AS rn
   FROM dbo.FactResellerSales a
) a
INNER JOIN dbo.DimSalesTerritory s ON a.SalesTerritoryKey = s.SalesTerritoryKey
CROSS APPLY
(
   SELECT SalesAmount 
   FROM Counts b
   WHERE a.SalesTerritoryKey = b.SalesTerritoryKey AND a.rn = b.c
) b
GROUP BY a.SalesTerritoryKey, s.SalesTerritoryRegion;

--1	600.156000

-- Solution by Itzik Ben-Gan Using APPLY and OFFSET-FETCH
WITH C AS
(
  SELECT SalesTerritoryKey,
    COUNT(*) AS cnt,
    (COUNT(*) - 1) / 2 AS offset_val,
    2 - COUNT(*) % 2 AS fetch_val
  FROM dbo.FactResellerSales
  GROUP BY SalesTerritoryKey
)
SELECT SalesTerritoryKey, AVG(1. * SalesAmount) AS median
FROM C
  CROSS APPLY ( SELECT O.SalesAmount
                FROM dbo.FactResellerSales AS O
                where O.SalesTerritoryKey = C.SalesTerritoryKey
                order by O.SalesAmount
                OFFSET C.offset_val ROWS FETCH NEXT C.fetch_val ROWS ONLY ) AS A
GROUP BY SalesTerritoryKey;