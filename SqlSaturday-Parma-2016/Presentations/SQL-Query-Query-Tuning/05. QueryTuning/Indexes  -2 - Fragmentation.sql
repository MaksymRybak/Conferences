--
-- Clustered index fragmentation
--
-- Recap: 
--   Internal fragmentation = space wasted within the data page
--   External fragmentation = logical order does not match the physical order
--

SET NOCOUNT ON

--Change database connection
USE AdventureWorks2014;

--Create table with test data
IF OBJECT_ID('tTable_data') IS NOT NULL
DROP TABLE tTable_data;

CREATE TABLE tTable_data 
(
Col1 VARCHAR(10) 
,Col2 VARCHAR(10) 
);

--Create indexes on tTable_data
CREATE CLUSTERED INDEX cl_tTable_data ON tTable_data(Col1);
CREATE NONCLUSTERED INDEX ncl_tTable_data ON tTable_data(Col2);

--Populate table with data
--This method will cause page splits in the clustered index and leave the index fragmented
DECLARE @intCounter INT
SET @intCounter = 1

WHILE @intCounter < 10001
BEGIN

	INSERT INTO tTable_data VALUES(@intCounter,@intCounter)
	INSERT INTO tTable_data VALUES(53-@intCounter,@intCounter)
 	
	SET @intCounter = @intCounter + 1
END;

--View fragmented indexes on tTable_data
SELECT 
		DB_NAME(database_id) AS 'Database Name'
		,[object_id] AS 'Object ID'
		,index_id AS 'Index ID'
		,avg_fragmentation_in_percent AS 'External Fragmentation'
		,avg_page_space_used_in_percent AS 'Internal Fragmentation' 
FROM	sys.dm_db_index_physical_stats(
			DB_ID('AdventureWorks2014'),
			OBJECT_ID('tTable_data'),
			NULL, NULL, 'DETAILED')
WHERE	avg_fragmentation_in_percent > 10 
OR 
avg_page_space_used_in_percent < 75
AND avg_page_space_used_in_percent <> 0
AND page_count > 8;

--Database Name	Object ID	Index ID	External Fragmentation	Internal Fragmentation
--AdventureWorks2014	967674495	1	84.6938775510204	63.7179021497406
--AdventureWorks2014	967674495	2	23.5294117647059	58.9467877440079

--Reorganize clustered index
ALTER INDEX cl_tTable_data ON tTable_data REORGANIZE;

--View clustered index fragmentation levels
SELECT 
		DB_NAME(database_id) AS 'Database Name'
		,[object_id] AS 'Object ID'
		,index_id AS 'Index ID'
		,avg_fragmentation_in_percent AS 'External Fragmentation'
		,avg_page_space_used_in_percent AS 'Internal Fragmentation' 
FROM sys.dm_db_index_physical_stats(
		DB_ID('AdventureWorks2014'),
		OBJECT_ID('tTable_data'),
		1, NULL, 'DETAILED')

--Database Name	Object ID	Index ID	External Fragmentation	Internal Fragmentation
--AdventureWorks2014	967674495	1	1.58730158730159	99.1304670126019
--AdventureWorks2014	967674495	1	0	15.7029898690388

--Rebuild clustered index
ALTER INDEX cl_tTable_data ON tTable_data REBUILD;

--View clustered index fragmentation levels
SELECT DB_NAME(database_id) AS 'Database Name'
,[object_id] AS 'Object ID'
,index_id AS 'Index ID'
,avg_fragmentation_in_percent AS 'External Fragmentation'
,avg_page_space_used_in_percent AS 'Internal Fragmentation' 
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2014'),OBJECT_ID('tTable_data'),1,NULL,'DETAILED')

--Database Name	Object ID	Index ID	External Fragmentation	Internal Fragmentation
--AdventureWorks2014	967674495	1	0	99.1304670126019
--AdventureWorks2014	967674495	1	0	15.8388930071658

--Drop tables
IF OBJECT_ID('tTable_data') IS NOT NULL
DROP TABLE tTable_data;
