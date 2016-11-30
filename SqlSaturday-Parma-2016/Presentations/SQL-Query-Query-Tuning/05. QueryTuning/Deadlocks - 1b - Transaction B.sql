USE AdventureWorks2014
GO

BEGIN TRANSACTION
	UPDATE	HumanResources.Department
	SET		Name = Name + ' added text'
	WHERE	DepartmentID = 1

	WAITFOR DELAY '00:00:05'

	SELECT	* 
	FROM	Sales.SalesOrderDetail
	WHERE	SalesOrderID = 43659 AND SalesOrderDetailID = 1
COMMIT
