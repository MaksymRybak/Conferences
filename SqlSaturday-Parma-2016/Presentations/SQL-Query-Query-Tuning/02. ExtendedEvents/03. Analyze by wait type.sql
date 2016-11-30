--
-- Analyze queries (wait types)
--

USE TraceAnalyzer
GO

WITH waits_analyzed AS 
(
	SELECT  
		query_hash,
		query_plan_hash,
		event_interval,
		statement,
		wait_type,
		SUM(duration_ms) AS total_duration_ms,
		AVG(duration_ms) AS average_duration_ms,
			COALESCE(STDEVP(duration_ms), 0) AS stdev_duration_ms,
		MIN(duration_ms) AS min_duration_ms,
		MAX(duration_ms) AS max_duration_ms,
		SUM(signal_duration_ms) AS total_signal_duration_ms,
		AVG(signal_duration_ms) AS average_signal_duration_ms,
			COALESCE(STDEVP(signal_duration_ms), 0) AS stdev_signal_duration_ms,
		MIN(signal_duration_ms) AS min_signal_duration_ms,
		MAX(signal_duration_ms) AS max_signal_duration_ms
	FROM    
		waits
	GROUP BY 
		query_hash,
        query_plan_hash,
        event_interval,
        statement,
        wait_type
),
waits_ntile_cte AS 
(
	SELECT  DISTINCT
		query_hash,
		query_plan_hash,
		event_interval,
		statement,
		wait_type,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_50th,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_75th,
		PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_90th,
		PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_95th,
		PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS duration_99th,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_50th,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_75th,
		PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_90th,
		PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_95th,
		PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY signal_duration_ms) OVER (PARTITION BY query_hash, query_plan_hash, event_interval, statement, wait_type) AS signal_duration_99th
	FROM    
		waits
),
wait_rank AS 
(
	SELECT  query_hash, query_plan_hash, event_interval, statement,
	SUM(total_duration_ms) r
	FROM    
		waits_analyzed
	GROUP BY 
		query_hash, 
		query_plan_hash, 
		event_interval, 
		statement
),
waits AS 
(
	SELECT  wc.query_hash,
		wc.query_plan_hash,
		wc.event_interval,
		wc.statement,
		wc.wait_type,
		wc.total_duration_ms ,
		wc.average_duration_ms,
		wc.stdev_duration_ms,
		wc.min_duration_ms,
		wc.max_duration_ms,
		wnc.duration_50th,
		wnc.duration_75th,
		wnc.duration_90th,
		wnc.duration_95th,
		wnc.duration_99th,
		wc.total_signal_duration_ms,
		wc.average_signal_duration_ms,
		wc.stdev_signal_duration_ms,
		wc.min_signal_duration_ms,
		wc.max_signal_duration_ms,
		wnc.signal_duration_50th,
		wnc.signal_duration_75th,
		wnc.signal_duration_90th,
		wnc.signal_duration_95th,
		wnc.signal_duration_99th
	FROM    
		waits_analyzed wc
	JOIN 
		waits_ntile_cte as wnc	
			ON wc.query_hash = wnc.query_hash
				AND wc.query_plan_hash = wnc.query_plan_hash
				AND wc.event_interval = wnc.event_interval
				AND wc.statement = wnc.statement
				AND wc.wait_type = wnc.wait_type
	JOIN 
		wait_rank AS wr 
			ON wc.query_hash = wr.query_hash
				AND wc.query_plan_hash = wr.query_plan_hash
				AND wc.event_interval = wr.event_interval
				AND wc.statement = wr.statement
)
SELECT  
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(w.statement)), NCHAR(13), ' '), NCHAR(10), ' '), NCHAR(9), ' '), ' ','<>'),'><',''),'<>',' ') AS QueryText,
	w.event_interval,
	w.wait_type,
	w.total_duration_ms AS wait_total_duration_ms,
	w.average_duration_ms AS wait_average_duration_ms,
	w.stdev_duration_ms AS wait_stdev_duration_ms,
	w.min_duration_ms AS wait_min_duration_ms,
	w.max_duration_ms AS wait_max_duration_ms,
	w.duration_50th AS wait_duration_50th,
	w.duration_75th AS wait_duration_75th,
	w.duration_90th AS wait_duration_90th,
	w.duration_95th AS wait_duration_95th,
	w.duration_99th AS wait_duration_99th,
	w.total_signal_duration_ms AS signal_wait_total_duration_ms,
	w.average_signal_duration_ms AS signal_wait_average_duration_ms,
	w.stdev_signal_duration_ms AS signal_wait_stdev_duration_ms,
	w.min_signal_duration_ms AS signal_wait_min_duration_ms,
	w.max_signal_duration_ms AS signal_wait_max_duration_ms,
	w.signal_duration_50th AS signal_wait_duration_50th,
	w.signal_duration_75th AS signal_wait_duration_75th,
	w.signal_duration_90th AS signal_wait_duration_90th,
	w.signal_duration_95th AS signal_wait_duration_95th,
	w.signal_duration_99th AS signal_wait_duration_99th,
	w.query_hash,
	w.query_plan_hash
FROM    
	waits w
ORDER BY 
	w.event_interval ASC, 
	w.total_duration_ms DESC
OPTION (RECOMPILE) ;