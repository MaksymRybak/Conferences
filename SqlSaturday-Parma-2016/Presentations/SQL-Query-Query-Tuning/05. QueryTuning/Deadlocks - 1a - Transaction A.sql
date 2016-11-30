USE AdventureWorks2014
GO

BEGIN TRANSACTION
	UPDATE	Sales.SalesOrderDetail
	SET		OrderQty = OrderQty * 2
	WHERE	SalesOrderID = 43659 AND SalesOrderDetailID = 1

	WAITFOR DELAY '00:00:05'

	SELECT	* 
	FROM	HumanResources.Department
	WHERE	DepartmentID = 1
COMMIT
GO