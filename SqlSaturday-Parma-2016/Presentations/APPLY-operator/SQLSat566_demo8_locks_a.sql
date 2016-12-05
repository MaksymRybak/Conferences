--SQL Saturday 566. Parma 26 november 2016. 
--Demo are based on sample db AdventureWorks2014. 
--6. Locks troubleshooting. Blocking session. 

USE AdventureWorks2014;
GO

BEGIN TRAN
UPDATE HumanResources.Employee SET SalariedFlag = 1 WHERE LoginID = 'adventure-works\garrett0';

--COMMIT TRAN
--ROLLBACK TRAN