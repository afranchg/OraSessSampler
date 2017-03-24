--Summary of events in percentage related to a column total samples for this column
--
-- Example, Summary of SQL_IDs in the period:
--   
-- SQL> @samsumcol sql_id %
--
--     TOTAL        ACT SQL_ID                 % STATE   SW_EVENT
------------ ---------- ------------- ---------- ------- ----------------------------------------------------------------
--        99         54 05nmmw3cs6kmr      54.55 WORKING On CPU / runqueue
--        99         15 05nmmw3cs6kmr      15.15 WAITING direct path write
--        99         10 05nmmw3cs6kmr       10.1 WAITING gc current request
--        99          9 05nmmw3cs6kmr       9.09 WAITING db file sequential read
--        99          6 05nmmw3cs6kmr       6.06 WAITING direct path read
--        99          3 05nmmw3cs6kmr       3.03 WAITING enq: SV -  contention
--        99          1 05nmmw3cs6kmr       1.01 WAITING gc buffer busy acquire
--        99          1 05nmmw3cs6kmr       1.01 WAITING gc current multi block request
--         2          1 10mt8w07jg060         50 WAITING gc cr request
--         2          1 10mt8w07jg060         50 WAITING log file sync
--         2          1 1rm4ja7nzbbf6         50 WAITING log file sync
--         2          1 1rm4ja7nzbbf6         50 WAITING rdbms ipc reply
--
-- We see that for sql_id  05nmmw3cs6kmr whe have 99 samples. 54 samples (54,5%) spent in CPU, 15 samples (15,1%) in direct path write, etc..
-- For SQL_ID 10mt8w07jg060 we have only 2 samples. 1 (50%) spent in gc cr request and the other one (50%) spent in log file sync, etc...
--
-- Summary of one SQL_ID:
-- SQL> @samsumcol sql_id 05nmmw3cs6kmr
--
--     TOTAL        ACT SQL_ID                 % STATE   SW_EVENT
------------ ---------- ------------- ---------- ------- ----------------------------------------------------------------
--        99         54 05nmmw3cs6kmr      54.55 WORKING On CPU / runqueue
--        99         15 05nmmw3cs6kmr      15.15 WAITING direct path write
--        99         10 05nmmw3cs6kmr       10.1 WAITING gc current request
--        99          9 05nmmw3cs6kmr       9.09 WAITING db file sequential read
--        99          6 05nmmw3cs6kmr       6.06 WAITING direct path read
--        99          3 05nmmw3cs6kmr       3.03 WAITING enq: SV -  contention
--        99          1 05nmmw3cs6kmr       1.01 WAITING gc buffer busy acquire
--        99          1 05nmmw3cs6kmr       1.01 WAITING gc current multi block request
-- SQL>

-- We can use any other column from SESMON. (sid, program , etc)
--   @samp_summary sid %
--   @samsum sid 14
-- @samsumcol program %

   
def columna = &1
def valor = &2

With p as (
select
       count(*) as act, &&columna,
      CASE WHEN state != 'WAITING' THEN 'WORKING'
            ELSE 'WAITING'
      END AS state,
       CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
            ELSE event
       END AS sw_event
    FROM sesmon
    where &&columna like '%&&valor%'
    and sample_id between &&sini and &&sfin
    group by
    CASE WHEN state != 'WAITING' THEN 'WORKING'
            ELSE 'WAITING'
      END ,
       CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
            ELSE event
       END ,  &&columna)
select  sum(act) over(partition by &&columna) as total, act, &&columna , round((act*100)/sum(act) over(partition by &&columna),2) as "%",state, sw_event from p order by 3,4 desc
/
undef columna
undef valor