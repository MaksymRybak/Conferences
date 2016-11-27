---- SQLSaturday 566 Parma 26-11-2016
---- Saverio Lorenzini - Query Store Demos

select * from sys.dm_exec_cached_plans
select * from sys.dm_exec_query_stats

--Recupero di un piano

select * from sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(plan_handle) TXT
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
WHERE TXT.text like '%Black%'
OPTION (RECOMPILE)

SET ANSI_NULLS ON;
SET NOCOUNT ON

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE Color = 'Black'  
AND  DaysToManufacture < 5
ORDER BY Name ASC; 

dbcc freeproccache
---------------------------------------------------
---------------------------------------------------
---variabilità di un piano
---- Query in Context Settings

CREATE TABLE dbo.t1 (a INT NULL);
INSERT INTO dbo.t1 VALUES (NULL),(0),(1);
GO

SELECT a FROM t1

SET ANSI_NULLS OFF;
SELECT * FROM t1 WHERE a <> null

SET ANSI_NULLS ON;
SELECT * FROM t1 WHERE a <> null

DROP TABLE t1
SET ANSI_NULLS ON;

select * from  sys.dm_exec_plan_attributes()
WHERE attribute = 'set_options'

--##presenza del query_id

---- QS DMVs
SELECT * FROM sys.query_store_plan
SELECT * FROM sys.query_store_query
SELECT * FROM sys.query_store_query_text

SELECT * FROM sys.query_store_runtime_stats
SELECT * FROM sys.query_store_runtime_stats_interval

SELECT * FROM sys.database_query_store_options
SELECT * FROM sys.query_context_settings

------1. posso avere più query con lo stesso testo:
SELECT query_text_id, count(query_id)
FROM sys.query_store_query
GROUP BY query_text_id
order by 2 desc

-------1,2,3 Focus on Navigation

------ 4. Focus on query
SELECT  sod.SalesOrderID,
        sod.SalesOrderDetailID,
        sod.CarrierTrackingNumber,
        sod.SpecialOfferID,
        sod.ModifiedDate,
        soh.OrderDate,
        soh.ShipDate,
        soh.TotalDue
FROM Sales.SalesOrderDetail sod
INNER JOIN Sales.SalesOrderHeader soh
ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.ModifiedDate > '20080304'
And [UnitPriceDiscount] > 3433

---- cerco la query
select * from sys.query_store_query_text
where query_sql_text like '%20080306%'

select * from sys.query_store_query
where query_text_id = 269


CREATE NONCLUSTERED INDEX [SQLSat1]
ON [Sales].[SalesOrderDetail] ([UnitPriceDiscount],[ModifiedDate])
INCLUDE ([SalesOrderID],[SalesOrderDetailID],[CarrierTrackingNumber],[SpecialOfferID])


CREATE NONCLUSTERED INDEX [SQLSat2] ON [Sales].[SalesOrderHeader]
([SalesOrderID] ASC)
INCLUDE ( [OrderDate],
          [ShipDate],
          [SubTotal],
          [TaxAmt],
          [Freight]) ON [PRIMARY]


-- BEYOND Query Store
--Which are queries with more query plan
select  query_id, count(plan_id)
from sys.query_store_plan
group by query_id
order by 2 desc

