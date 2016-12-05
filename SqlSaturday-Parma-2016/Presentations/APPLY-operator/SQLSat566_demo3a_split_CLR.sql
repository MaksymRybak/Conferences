--SQL Saturday 566. Parma 26 november 2016. 
--3 CLR TVF function to spit strings 
--Credits to Adam Machanic for writing the SQLCLR function: http://sqlblog.com/blogs/adam_machanic/archive/2009/04/28/sqlclr-string-splitting-part-2-even-faster-even-more-scalable.aspx
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

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'ufn_SplitStringCLR' AND type = 'FT')
DROP FUNCTION dbo.ufn_SplitStringCLR;

IF EXISTS (SELECT * FROM sys.assemblies WHERE name = 'ass_SplitStringCLR')
DROP ASSEMBLY ass_SplitStringCLR;

-- dll path: E:\SQL_Server\SQL_Saturday\566_Parma_26-11-2016\SplitStringCLR\SplitStringCLR\bin\Debug\SplitStringCLR.dll
--replace with your path
CREATE ASSEMBLY ass_SplitStringCLR FROM 'E:\SQL_Server\SQL_Saturday\566_Parma_26-11-2016\SplitStringCLR\SplitStringCLR\bin\Debug\SplitStringCLR.dll' 
WITH PERMISSION_SET = SAFE;
GO


--Create a User Defined TVF CLR Function assembly_name.[namespace.class_name].method_name
CREATE FUNCTION dbo.ufn_SplitStringCLR (@List nvarchar(max), @Delimiter nvarchar(255))
RETURNS TABLE( list nvarchar(max))
AS EXTERNAL NAME ass_SplitStringCLR.UserDefinedFunctions.SplitString_Multi; 
GO

--Test the function
SELECT * FROM dbo.ufn_SplitStringCLR('pippo;pluto;paperino;topolino',';');

--Use the function in conjunction with a table 
SELECT 
	rl.RegionName,
	spfn.list
FROM dbo.RegionList rl
CROSS APPLY dbo.ufn_SplitStringCLR(rl.Province,'|') spfn
