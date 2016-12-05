--SQL Saturday 566. Parma 26 november 2016. 
--3b CLR TVF to retrieve external file info
-- In Visual Studio, copy and compile the code, to create a dll  

USE Test;
GO

--Check the settings;
SELECT is_trustworthy_on FROM sys.databases WHERE name = 'Test';

--Set proper permissions on the database
ALTER DATABASE [Test] 
SET TRUSTWORTHY ON
GO
--The TRUSTWORTHY database property is used to indicate whether the instance of SQL Server trusts the database and the contents within it." 

--Enable CLR integration
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'ufn_GetFileInfoCLR' AND type = 'FT')
DROP FUNCTION dbo.ufn_GetFileInfoCLR;

IF EXISTS (SELECT * FROM sys.assemblies WHERE name = 'ass_GetFileInfoCLR')
DROP ASSEMBLY ass_GetFileInfoCLR;

-- dll path: ClrTableValuedFunction -> E:\SQL_Server\SQL_Saturday\566_Parma_26-11-2016\ClrTableValuedFunction\ClrTableValuedFunction\bin\Debug\ClrTableValuedFunction.dll
--replace with your path
CREATE ASSEMBLY ass_GetFileInfoCLR FROM 'E:\SQL_Server\SQL_Saturday\566_Parma_26-11-2016\ClrTableValuedFunction\ClrTableValuedFunction\bin\Debug\ClrTableValuedFunction.dll' 
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO


--Create a User Defined TVF CLR Function assembly_name.[namespace.class_name].method_name
CREATE FUNCTION dbo.ufn_GetFileInfoCLR (@FilePath nvarchar(400))
RETURNS TABLE(FileName nvarchar(256), FileSize bigint, FileDateModified datetime)
AS EXTERNAL NAME ass_GetFileInfoCLR.UserDefinedFunctions.ReadDirectoryFileInfo; 
GO

--Test the function
SELECT FileName, FileSize, FileDateModified FROM dbo.ufn_GetFileInfoCLR(N'C:\temp\');

--Create a table with a list of directories to scan
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'DirectoryList' AND schema_id = SCHEMA_ID('dbo'))
DROP TABLE dbo.DirectoryList;
GO


CREATE TABLE dbo.DirectoryList (
	DirectoryName nvarchar(400)
);

INSERT INTO dbo.DirectoryList(DirectoryName)
VALUES('C:\'),('E:\'),('F:\'),
('E:\Musica\Eagles\CD1'),
('E:\Musica\Eagles\CD2'),
('E:\Musica\Pink Floyd\The_Wall'),
('C:\temp\EmptyDirectory');

--TRUNCATE TABLE dbo.DirectoryList

--Use the function in conjunction with a table 
SELECT 
	dl.DirectoryName,
	fi.FileName,
	fi.FileDateModified,
	fi.FileSize
FROM dbo.DirectoryList dl  
OUTER APPLY dbo.ufn_GetFileInfoCLR(dl.DirectoryName) fi
ORDER BY dl.DirectoryName, fi.FileName

