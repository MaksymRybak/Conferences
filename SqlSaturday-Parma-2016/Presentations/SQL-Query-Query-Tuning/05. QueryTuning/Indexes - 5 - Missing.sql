--
-- Indici mancanti o inaccurati
--
USE AdventureWorks2014;
GO

DBCC FREEPROCCACHE;

SET STATISTICS IO ON
GO
SET STATISTICS TIME ON
GO

SELECT  soh.AccountNumber,
        sod.LineTotal,
        sod.OrderQty,
        sod.UnitPrice,
        p.Name
FROM    Sales.SalesOrderHeader soh
        JOIN Sales.SalesOrderDetail sod
        ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Production.Product p
        ON sod.ProductID = p.ProductID
WHERE   sod.LineTotal > 1000; 
GO

SET STATISTICS IO OFF
GO
SET STATISTICS TIME OFF 
GO

/*

DBCC execution completed. If DBCC printed error messages, contact your system administrator.
SQL Server parse and compile time: 
   CPU time = 13 ms, elapsed time = 13 ms.

(32101 row(s) affected)
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderDetail'. Scan count 1, logical reads 1246, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 668, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Product'. Scan count 1, logical reads 6, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 125 ms,  elapsed time = 414 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

-------

DBCC execution completed. If DBCC printed error messages, contact your system administrator.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 13 ms.

(32101 row(s) affected)
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderDetail'. Scan count 1, logical reads 183, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Product'. Scan count 1, logical reads 6, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 689, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(1 row(s) affected)

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 333 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

*/

/*
Missing Index Details from ... 
The Query Processor estimates that implementing the following index 
could improve the query cost by 46.1418%.

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_LineTotal]
ON [Sales].[SalesOrderDetail] ([LineTotal])
INCLUDE ([SalesOrderID],[OrderQty],[ProductID],[UnitPrice])
GO
*/

-- Cleanup
-- <r
