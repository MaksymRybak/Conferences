--
-- Indici errati
--

SET NOCOUNT ON

--Change database connection
USE AdventureWorks2014;

--Create tables with test data
IF OBJECT_ID('t1') IS NOT NULL
DROP TABLE t1;

CREATE TABLE t1
(
Col1 VARCHAR(10) 
,Col2 VARCHAR(10) 
);

IF OBJECT_ID('t2') IS NOT NULL
DROP TABLE t2;

CREATE TABLE t2
(
Col1 VARCHAR(10) 
,Col2 VARCHAR(10) 
);

--Populate table with data
--This method will cause page splits in the clustered index and leave the index fragmented
DECLARE @intCounter INT
SET @intCounter = 1

WHILE @intCounter < 10001
BEGIN

	INSERT INTO t1 VALUES(@intCounter,@intCounter)
	INSERT INTO t2 VALUES(@intCounter,@intCounter)
 	
	SET @intCounter = @intCounter + 1
END;

--Execute query against tables
SET STATISTICS PROFILE ON;
SET STATISTICS IO ON;

--Table scans performed
SELECT t1.col2, t2.col2
FROM t1 t1
INNER JOIN t2 t2
ON t1.col1 = t2.col1
WHERE t1.col1 = '2000';
--WHERE t1.col1 = 2000;

--Create index
CREATE NONCLUSTERED INDEX ncl_t1 ON t1(Col1);
CREATE NONCLUSTERED INDEX ncl_t2 ON t2(Col1);

--Execute query against tables
--Bookmark lookups performed
SELECT t1.col2, t2.col2
FROM t1 t1
INNER JOIN t2 t2
ON t1.col1 = t2.col1
WHERE t1.col1 = '2000';
--WHERE t1.col1 = 2000;

--Correct indexes
DROP INDEX t1.ncl_t1;
DROP INDEX t2.ncl_t2;

CREATE NONCLUSTERED INDEX ncl_t1 ON t1(Col1,Col2);
CREATE NONCLUSTERED INDEX ncl_t2 ON t2(Col1,Col2);

--No table scans or bookmark lookups
SELECT t1.col2, t2.col2
FROM t1 t1
INNER JOIN t2 t2
ON t1.col1 = t2.col1
WHERE t1.col1 = '2000';
--WHERE t1.col1 = 2000;

SET STATISTICS PROFILE OFF;
SET STATISTICS IO OFF;

--Drop tables
IF OBJECT_ID('t1') IS NOT NULL
DROP TABLE t1;

IF OBJECT_ID('t2') IS NOT NULL
DROP TABLE t2;


