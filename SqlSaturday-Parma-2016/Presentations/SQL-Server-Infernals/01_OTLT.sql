-- =============================================
-- Author:      Gianluca Sartori - @spaghettidba
-- Create date: 2016-09-07
-- Description: Creates the One True Lookup Table
-- =============================================
USE tempdb;
GO

IF OBJECT_ID('LookupTable') IS NOT NULL
	DROP TABLE LookupTable;
GO

CREATE TABLE LookupTable (
	table_name sysname,
	lookup_code nvarchar(500),
	lookup_description nvarchar(4000),
	PRIMARY KEY CLUSTERED(table_name, lookup_code),
	CHECK(
		CASE 
			WHEN lookup_code = 'states'     AND lookup_code LIKE '[A-Z][A-Z]'      THEN 1
			WHEN lookup_code = 'priorities' AND lookup_code LIKE '[0-8]'           THEN 1
			WHEN lookup_code = 'countries'  AND lookup_code LIKE '[A-Z][A-Z][A-Z]' THEN 1
			WHEN lookup_code = 'status'     AND lookup_code LIKE '[A-Z][A-Z]'      THEN 1
			ELSE 0
		END = 1
	)
)


INSERT INTO LookupTable 
	(table_name, lookup_code, lookup_description)
VALUES 
	('countries','ITA','Italy'),
	('countries','DEN','Denmark'),
	('countries','SLO','Slovenia'),
	--
	('states','CO','Colorado'),
	('states','NY','New York'),
	('states','WA','Washington'),
	--
	('priorities','1','High Priority'),
	('priorities','2','Normal Priority'),
	('priorities','3','Low Priority'),
	--
	('status','RC','Received'),
	('status','SH','Shipped'),
	('status','CN','Canceled');

