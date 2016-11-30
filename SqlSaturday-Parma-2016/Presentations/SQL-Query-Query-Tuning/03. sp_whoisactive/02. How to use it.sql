--
-- 02. How to use it
-- http://sqlblog.com/blogs/adam_machanic/archive/tags/month+of+monitoring/default.aspx
--

EXEC sp_whoisactive;

EXEC sp_whoisactive @help = 1;

EXEC sp_whoisactive @get_plans = 1;

EXEC sp_whoisactive 
	@filter_type = 'database',
	@filter = 'AdventureWorks2014';

EXEC sp_whoisactive
	@find_block_leaders = 1, 
    @sort_order = '[blocked_session_count] DESC';

	