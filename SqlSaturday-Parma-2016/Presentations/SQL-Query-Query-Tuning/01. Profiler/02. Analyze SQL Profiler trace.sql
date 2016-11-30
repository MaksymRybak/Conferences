--
-- 02. Analyze SQL Trace
--

--
-- Find my trace -  WARNING !!! traceid = 1 is SQL Server default trace
--
SELECT * FROM fn_trace_getinfo(0)

-- Stop the trace
EXEC sp_trace_setstatus @traceid = 2, @status = 0
-- Delete the trace
EXEC sp_trace_setstatus @traceid = 2, @status = 2

--
-- Import SQL trace into a table for analysis
-- Ref: https://www.simple-talk.com/sysadmin/powershell/fun-with-sql-server-profiler-trace-files-and-powershell/
--

-- If not exists, create a database for trace analysis
IF DB_ID('TraceAnalyzer') IS NULL
BEGIN
	CREATE DATABASE [TraceAnalyzer];
END

USE [TraceAnalyzer];
GO

-- Import a trace file into a table
SELECT * INTO trace_analyzer
FROM fn_trace_gettable('C:\Demos\QueryPerformanceTrace.trc', default);
GO

SELECT * 
FROM trace_analyzer

