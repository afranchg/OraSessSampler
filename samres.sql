--This script extracts a summary in terms of percentage related to a column related to the given period.
-- Este script extrae un sumario en terminos de porcentaje de una columna en relacion al periodo
-- Ex:
-- To show the more active sids in the period in terms of percentage relative to the number of samples:
-- @samres.sql sid
--SQL> @sampres sid
--
--     TOTAL        ACT          %        SID
--  ---------- ---------- ---------- ----------
--       339         76      22.42        363
--       339         55      16.22        194
--       339         52      15.34        819
--       339         50      14.75       1275
--       339         42      12.39        626
--       339         42      12.39        602
--       339          6       1.77        122
--       339          4       1.18       1298
--       339          3        .88         50
--       339          2        .59        434
--       339          2        .59       1393
--
--     TOTAL        ACT          %        SID
------------ ---------- ---------- ----------
--       339          1        .29        939
--       339          1        .29        962
--       339          1        .29        458
--       339          1        .29        843
--       339          1        .29       1034
-- SQL>
-- The previous output shows that over 339 samples, sid 363 is active in 76 samples (22,42% of total), sid 194 is active in 55 samples (16,2% of total), etc.
-- Same for events or any other column of SESMON:
-- @samres.sql event
-- @samres.sql program

set autoprint on
set lines 200
variable x refcursor

begin
if '&1' = 'event' then
open :x for
with p as(
select
       count(*) as act,
      CASE WHEN state != 'WAITING' THEN 'WORKING'
            ELSE 'WAITING'
      END AS state,
       CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
            ELSE event
       END AS sw_event
    FROM sesmon
   where sample_id between &&sini and &&sfin
    group by
    CASE WHEN state != 'WAITING' THEN 'WORKING'
            ELSE 'WAITING'
      END ,
       CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
            ELSE event
       END)
 select  sum(act) over() as total, act, round((act*100)/sum(act) over(),2) as "%" , sw_event from p order by 3 desc;
else
open :x for with p as(select count(*) as act, &1 from sesmon where sample_id between &&sini and &&sfin group by &1) select  sum(act) over() as total, act, round((act*100)/sum(act) over(),2) as "%" , &1 from p order by 3 desc;
end if;
end;
/
