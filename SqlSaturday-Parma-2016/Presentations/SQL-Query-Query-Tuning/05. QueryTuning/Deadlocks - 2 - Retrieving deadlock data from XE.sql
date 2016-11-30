/*
with XmlDataSet as(
	SELECT CAST(xet.target_data AS XML) AS XMLDATA,*
	FROM sys.dm_xe_session_targets xet
		INNER JOIN sys.dm_xe_sessions xe ON (xe.address = xet.event_session_address)
	WHERE xe.name = 'system_health'
		  and target_name = 'ring_buffer'   -- IN SQL 2012+ there is 2 targets: ring_buffer and event_file
)
	SELECT cast(C.query('.') as xml) EventXML
	FROM XmlDataSet a
	CROSS APPLY a.XMLDATA.nodes('/RingBufferTarget/event') as T(C)
	WHERE C.query('.').value('(/event/@name)[1]', 'varchar(255)') in ('xml_deadlock_report')

*/

--
-- Extract deadlock information from system_health XE session (ring buffer)
--
with XmlDataSet as(
	SELECT CAST(xet.target_data AS XML) AS XMLDATA,*
	FROM sys.dm_xe_session_targets xet
		INNER JOIN sys.dm_xe_sessions xe ON (xe.address = xet.event_session_address)
	WHERE xe.name = 'system_health'
		  and target_name = 'ring_buffer'   -- IN SQL 2012 there is 2 targets: ring_buffer and event_file
),
 CTE_HealthSession (EventXML) AS (
	SELECT cast(C.query('.') as xml) EventXML
	FROM XmlDataSet a
	CROSS APPLY a.XMLDATA.nodes('/RingBufferTarget/event') as T(C)
	WHERE C.query('.').value('(/event/@name)[1]', 'varchar(255)') in ('xml_deadlock_report')
)
--SELECT EventXML FROM CTE_HealthSession
SELECT DeadlockProcesses.value('(@id)[1]','varchar(50)') as id
,DeadlockProcesses.value('(@taskpriority)[1]','bigint') as taskpriority
,DeadlockProcesses.value('(@logused)[1]','bigint') as logused
,DeadlockProcesses.value('(@waitresource)[1]','varchar(100)') as waitresource
,DeadlockProcesses.value('(@waittime)[1]','bigint') as waittime
,DeadlockProcesses.value('(@ownerId)[1]','bigint') as ownerId
,DeadlockProcesses.value('(@transactionname)[1]','varchar(50)') as transactionname
,DeadlockProcesses.value('(@lasttranstarted)[1]','varchar(50)') as lasttranstarted
,DeadlockProcesses.value('(@XDES)[1]','varchar(20)') as XDES
,DeadlockProcesses.value('(@lockMode)[1]','varchar(5)') as lockMode
,DeadlockProcesses.value('(@schedulerid)[1]','bigint') as schedulerid
,DeadlockProcesses.value('(@kpid)[1]','bigint') as kpid
,DeadlockProcesses.value('(@status)[1]','varchar(20)') as status
,DeadlockProcesses.value('(@spid)[1]','bigint') as spid
,DeadlockProcesses.value('(@sbid)[1]','bigint') as sbid
,DeadlockProcesses.value('(@ecid)[1]','bigint') as ecid
,DeadlockProcesses.value('(@priority)[1]','bigint') as priority
,DeadlockProcesses.value('(@trancount)[1]','bigint') as trancount
,DeadlockProcesses.value('(@lastbatchstarted)[1]','varchar(50)') as lastbatchstarted
,DeadlockProcesses.value('(@lastbatchcompleted)[1]','varchar(50)') as lastbatchcompleted
,DeadlockProcesses.value('(@clientapp)[1]','varchar(150)') as clientapp
,DeadlockProcesses.value('(@hostname)[1]','varchar(50)') as hostname
,DeadlockProcesses.value('(@hostpid)[1]','bigint') as hostpid
,DeadlockProcesses.value('(@loginname)[1]','varchar(150)') as loginname
,DeadlockProcesses.value('(@isolationlevel)[1]','varchar(150)') as isolationlevel
,DeadlockProcesses.value('(@xactid)[1]','bigint') as xactid
,DeadlockProcesses.value('(@currentdb)[1]','bigint') as currentdb
,DeadlockProcesses.value('(@lockTimeout)[1]','bigint') as lockTimeout
,DeadlockProcesses.value('(@clientoption1)[1]','bigint') as clientoption1
,DeadlockProcesses.value('(@clientoption2)[1]','bigint') as clientoption2
FROM CTE_HealthSession D
CROSS APPLY eventxml.nodes('//deadlock/process-list/process') AS R(DeadlockProcesses);

--
-- Waitresource:
--   KEY: 9:72057594048479232 (0ca7b7436f59)
--        ^        ^                ^
--        |        |                |
--        |        |                key hash
--        |        hobt_id
--        database_id

SELECT 
obj.name AS Table_Name, 
ind.name AS Index_Name,
SCHEMA_NAME(obj.schema_id) AS Schema_name
FROM sys.partitions par 
JOIN sys.objects obj ON par.OBJECT_ID = obj.OBJECT_ID 
JOIN sys.indexes ind ON par.OBJECT_ID = ind.OBJECT_ID AND par.index_id = ind.index_id 
WHERE par.hobt_id = 72057594048479232

--Table_Name	Index_Name	Schema_name
--SalesOrderDetail	PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID	Sales

SELECT %%lockres%%, * 
FROM Sales.SalesOrderDetail
WHERE %%lockres%% = '(0ca7b7436f59)'

-- (No column name)	SalesOrderID	SalesOrderDetailID	CarrierTrackingNumber	OrderQty	ProductID	SpecialOfferID	UnitPrice	UnitPriceDiscount	LineTotal	rowguid	ModifiedDate
-- (0ca7b7436f59)	43659	1	4911-403C-98	4	776	1	2024.994	0.00	8099.976000	B207C96D-D9E6-402B-8470-2CC176C42283	2011-05-31 00:00:00.000