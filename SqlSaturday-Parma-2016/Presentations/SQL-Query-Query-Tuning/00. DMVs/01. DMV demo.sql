--
-- DMVs
--

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--
-- Find slowest queries
--

SELECT TOP 10
			CAST(qs.total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS [Total Elapsed Duration (s)],
			qs.execution_count,
			SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,
			((CASE WHEN qs.statement_end_offset = -1
				THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
				ELSE
					qs.statement_end_offset
				END - qs.statement_start_offset)/2) + 1) AS [Individual Query],
			qt.text AS [Parent Query],
			DB_NAME(qt.dbid) AS DatabaseName,
			qp.query_plan
FROM		sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
INNER JOIN	sys.dm_exec_cached_plans cp	ON qs.plan_handle=cp.plan_handle
ORDER BY	total_elapsed_time DESC;

--
-- Find missing indexes
--

SELECT		
			DB_NAME(mid.database_id) as DatabaseName,  
			CONVERT (decimal (28,1), 
			migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)
			) AS improvement_measure, 
			'CREATE INDEX missing_index_' + CONVERT (nvarchar, mig.index_group_handle) + '_' + CONVERT (nvarchar, mid.index_handle) 
			+ ' ON ' + mid.statement 
			+ ' (' + ISNULL (mid.equality_columns,'') 
			+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
			+ ISNULL (mid.inequality_columns, '')
			+ ')' 
			+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement, 
			mig.index_group_handle,
			mid.index_handle,
			migs.[group_handle],
			migs.[unique_compiles],
			migs.[user_seeks],
			migs.[user_scans],
			migs.[last_user_seek],
			migs.[last_user_scan],
			migs.[avg_total_user_cost],
			migs.[avg_user_impact],
			migs.[system_seeks],
			migs.[system_scans],
			migs.[last_system_seek],
			migs.[last_system_scan],
			migs.[avg_total_system_cost],
			migs.[avg_system_impact]	,		
			mid.[object_id],
			statement           
FROM		sys.dm_db_missing_index_groups mig
INNER JOIN	sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN	sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE		CONVERT (decimal (28,1), 
			migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
ORDER BY	migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC;

--
-- Find query with missing statistics
--
SELECT TOP 10
			st.text AS [Parent Query]
			, DB_NAME(st.dbid)AS [DatabaseName]
			, cp.usecounts AS [Usage Count]
			, qp.query_plan
FROM		sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE		CAST(qp.query_plan AS NVARCHAR(MAX))
	LIKE '%<ColumnsWithNoStatistics>%'
ORDER BY	cp.usecounts DESC

--
-- Find parallel queries
--
SELECT TOP 10
			p.*,
			q.*,
			qs.*,
			cp.plan_handle
FROM		sys.dm_exec_cached_plans cp
CROSS apply sys.dm_exec_query_plan(cp.plan_handle) p
CROSS apply sys.dm_exec_sql_text(cp.plan_handle) AS q
JOIN		sys.dm_exec_query_stats qs ON qs.plan_handle = cp.plan_handle
WHERE		cp.cacheobjtype = 'Compiled Plan' 
	AND		p.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)', 'float') > 0
ORDER BY	max_elapsed_time DESC
OPTION		(MAXDOP 1) 

--
-- Find a cached plan
--
SELECT TOP 10
			st.text AS [SQL],
			cp.cacheobjtype,
			cp.objtype,
			COALESCE(DB_NAME(st.dbid),
			DB_NAME(CAST(pa.value AS INT))+'*', 
			'Resource') AS [DatabaseName],
			cp.usecounts AS [Plan usage],
			qp.query_plan
FROM		sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
OUTER APPLY sys.dm_exec_plan_attributes(cp.plan_handle) pa
WHERE		pa.attribute = 'dbid'
	AND		st.text LIKE '%SalesOrderDetail%'
