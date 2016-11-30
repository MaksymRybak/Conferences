--
-- Missing statistics
--

USE AdventureWorks2014;
GO

ALTER DATABASE AdventureWorks2014 SET AUTO_UPDATE_STATISTICS OFF ;

--
-- Setup
--
IF (SELECT OBJECT_ID('StatsDemo')) IS NOT NULL
DROP TABLE dbo.StatsDemo ;
GO

CREATE TABLE dbo.StatsDemo (C1 INT, C2 INT IDENTITY) ;

SELECT TOP 1500 IDENTITY( INT,1,1 ) AS n
INTO #Nums
FROM Master.dbo.SysColumns a,
Master.dbo.SysColumns b ;

INSERT INTO dbo.StatsDemo (C1)
SELECT n
FROM #Nums

DROP TABLE #Nums

CREATE NONCLUSTERED INDEX i1 ON dbo.StatsDemo (C1) ;

---------

SELECT *
FROM StatsDemo
WHERE C1 = 2;

SET NOCOUNT ON
INSERT INTO StatsDemo (C1) VALUES (2);
GO



SELECT TOP 1500
IDENTITY( INT,1,1 ) AS n
INTO #Nums
FROM Master.dbo.SysColumns scl,
Master.dbo.SysColumns sC2 ;

INSERT INTO dbo.StatsDemo (C1)
SELECT 2
FROM #Nums ;

DROP TABLE #Nums ;


DBCC SHOW_STATISTICS (StatsDemo, i1)


SELECT *
FROM StatsDemo
WHERE C1 = 2 ;


UPDATE STATISTICS StatsDemo

