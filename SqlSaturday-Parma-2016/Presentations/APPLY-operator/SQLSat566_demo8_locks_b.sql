--SQL Saturday 566. Parma 26 november 2016. 
--Demo are based on sample db AdventureWorks2014. 
--6. Locks troubleshooting. Blocked session. 

USE AdventureWorks2014;
GO

SELECT * FROM HumanResources.Employee
WHERE LoginID = 'adventure-works\garrett0';
