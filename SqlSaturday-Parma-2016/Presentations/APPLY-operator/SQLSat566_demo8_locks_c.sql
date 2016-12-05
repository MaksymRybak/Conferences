--SQL Saturday 566. Parma 26 november 2016. 
--Demo are based on sample db AdventureWorks2014. 
--6. Locks troubleshooting. 


USE AdventureWorks2014;
GO

--retreive my session ID
SELECT @@SPID;

SELECT 
	request_session_id,
	resource_type,
	DB_NAME(resource_database_id) AS dbname,
	resource_description, --Description of the resource that contains only information that is not available from other resource columns
	resource_associated_entity_id, --ID of the entity in a database with which a resource is associated.
	request_mode,
	request_type,

	request_status
FROM sys.dm_tran_locks;

--PAGE Represents a single page in a data file. <file_id>:<page_in_file> Represents the file and page ID of the page that is represented by this resource.

--Lock modes 
--IS = Intent shared. Protects requested or acquired shared locks on some (but not all) resources lower in the hierarchy.
--IX = Intent exclusive. Protects requested or acquired exclusive locks on some (but not all) resources lower in the hierarchy.

-- To get information about the connections involved in the blocking chain query the dmv sys.dm_exec_connections:
SELECT 
	session_id,
	connect_time,			--Timestamp when connection was established
	last_read,				--Timestamp when last read occurred over this connection
	last_write,				--Timestamp when last write occurred over this connection
	most_recent_session_id,	--Represents the session ID for the most recent request associated with this connection
	most_recent_sql_handle	--The SQL handle of the last request executed on this connection. t_recent_sql_handle column is always in sync with the most_recent_session_id column
FROM sys.dm_exec_connections
WHERE session_id IN(60,61)

--most_recent_sql_handle is a binary field holding the most recent SQL query ran by the connection.
--To get a readable value for the handle, you can apply the function sys.dm_exec_sql_text to the DMV

--remeber to switch to text for a better view of results window
SELECT 
	session_id,
	st.text
FROM sys.dm_exec_connections
	CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) as st
WHERE session_id IN(60,61)

--another useful DWMV is sys.dm_exec_requests which returns information about each request that is executing within SQL Server.:
SELECT 
	session_id,
	blocking_session_id,				--ID of the session that is blocking the request.
	command,							--Identifies the current type of command that is being processed			
	DB_NAME(database_id) AS dbname,
	wait_type,
	wait_time,
	wait_resource,
	sql_handle,							--Hash map of the SQL text of the request.
	st.text
FROM sys.dm_exec_requests 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
WHERE blocking_session_id > 0