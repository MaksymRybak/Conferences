--
-- Index analysis 
--

-- Run "Index - 0 - Setup sp_IndexAnalysis"

USE AdventureWorks2014
GO

EXEC dbo.sp_IndexAnalysis 
	@Output = 'DETAILED'
	,@TableName = NULL
	,@IncludeMissingIndexes = 1
	,@IncludeMissingFKIndexes = 0
