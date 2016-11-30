--
-- 03. Professional use
--

IF OBJECT_ID('[dbo].[exec_requests]', 'U') IS NULL
BEGIN

	CREATE TABLE [dbo].[exec_requests] 
	(
		[dd hh:mm:ss.mss]       VARCHAR (8000)  NULL,
		[session_id]            SMALLINT        NOT NULL,
		[sql_text]              XML             NULL,
		[login_name]            NVARCHAR (128)  NOT NULL,
		[wait_info]             NVARCHAR (4000) NULL,
		[tasks]                 VARCHAR (30)    NULL,
		[CPU]                   VARCHAR (30)    NULL,
		[tempdb_allocations]    VARCHAR (30)    NULL,
		[tempdb_current]        VARCHAR (30)    NULL,
		[blocking_session_id]   SMALLINT        NULL,
		[blocked_session_count] VARCHAR (30)    NULL,
		[reads]                 VARCHAR (30)    NULL,
		[writes]                VARCHAR (30)    NULL,
		[context_switches]      VARCHAR (30)    NULL,
		[physical_io]           VARCHAR (30)    NULL,
		[physical_reads]        VARCHAR (30)    NULL,
		[used_memory]           VARCHAR (30)    NULL,
		[status]                VARCHAR (30)    NOT NULL,
		[open_tran_count]       VARCHAR (30)    NULL,
		[percent_complete]      VARCHAR (30)    NULL,
		[host_name]             NVARCHAR (128)  NULL,
		[database_name]         NVARCHAR (128)  NULL,
		[program_name]          NVARCHAR (128)  NULL,
		[start_time]            DATETIME        NOT NULL,
		[login_time]            DATETIME        NULL,
		[request_id]            INT             NULL,
		[collection_time]       DATETIME        NOT NULL
	);
END

exec sp_whoisactive 
	@find_block_leaders = 1, 
	@get_task_info = 2, 
	@sort_order = 'session_id',
	@destination_table = '[dbo].[exec_requests]';

SELECT * FROM exec_requests


