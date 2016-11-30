--
-- Parameter sniffing
--

USE AdventureWorks2014;
GO

SET STATISTICS IO ON

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897;

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 945;

SELECT SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870;

IF OBJECT_ID('dbo.Get_Orders', 'P') IS NOT NULL
DROP PROC dbo.Get_Orders;
GO

CREATE PROCEDURE dbo.Get_Orders (@ProductID INT)
AS
	SET NOCOUNT ON

	SELECT SalesOrderDetailID, OrderQty
	FROM Sales.SalesOrderDetail
	WHERE ProductID = @ProductID;
GO

EXEC dbo.Get_Orders @ProductID = 870;
EXEC dbo.Get_Orders @ProductID = 945;



-- Opzioni disponibili

-- Opzione 1: ricompilazione
ALTER PROCEDURE dbo.Get_Orders (@ProductID INT)
WITH RECOMPILE
AS
	SET NOCOUNT ON

	SELECT SalesOrderDetailID, OrderQty
	FROM Sales.SalesOrderDetail
	WHERE ProductID = @ProductID;
GO

/*
Missing Index Details
The Query Processor estimates that implementing the following index 
could improve the query cost by 99.5852%.

USE [AdventureWorks2014]
GO
CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_01]
ON [Sales].[SalesOrderDetail] ([ProductID])
INCLUDE ([SalesOrderDetailID],[OrderQty])
GO
*/

EXEC dbo.Get_Orders @ProductID = 870;
EXEC dbo.Get_Orders @ProductID = 945;

-- Opzione 2: hint OPTIMIZE FOR
ALTER PROCEDURE dbo.Get_Orders (@ProductID INT)
AS
	SET NOCOUNT ON

	SELECT SalesOrderDetailID, OrderQty
	FROM Sales.SalesOrderDetail
	WHERE ProductID = @ProductID
	OPTION (OPTIMIZE FOR (@ProductID=945));
GO

EXEC dbo.Get_Orders @ProductID = 870;
EXEC dbo.Get_Orders @ProductID = 945;

--
-- Plan guide
--

ALTER PROCEDURE dbo.Get_Orders (@ProductID INT)
AS
	SET NOCOUNT ON

	SELECT SalesOrderDetailID, OrderQty
	FROM Sales.SalesOrderDetail
	WHERE ProductID = @ProductID;
GO

EXEC sp_create_plan_guide   
	@name = N'MyGuide',  
	@stmt = N'SELECT SalesOrderDetailID, OrderQty
		FROM Sales.SalesOrderDetail
		WHERE ProductID = @ProductID',  
	@type = N'OBJECT',  
	@module_or_batch = N'dbo.Get_Orders',  
	@params = NULL,  
	@hints = N'OPTION (OPTIMIZE FOR (@ProductID = 945))'; 

DECLARE @id int = 870
EXEC dbo.Get_Orders @ProductID = 870;
EXEC dbo.Get_Orders @ProductID = 945;

EXEC sp_control_plan_guide 'DROP', 'MyGuide';
