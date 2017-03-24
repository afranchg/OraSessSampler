-- Time line over a period. We have to pass the columns we want from SESMON and, when asked, a filtering condition. Add a comma after each column except the last
-- one
-- Ex:
-- @samtl.sql sid, sql_id, blocking_session
-- "ADD FILTERING CONDITION":
-- sid=14 (any condition ex: sid in (11,14), sid=14 and sql_id='xxxxx', etc )

alter session set nls_date_format='dd-mm-yy hh24:mi:ss';
col 1 new_value 1
col 2 new_value 2
col 3  new_value 3
col 4  new_value 4
col 5  new_value 5
col 6  new_value 6
col 7  new_value 7
col 8  new_value 8
col 9  new_value 9
col 10  new_value 10
col 11  new_value 11
col 12  new_value 12
col 13  new_value 13
col 14  new_value 14
col 15  new_value 15
col 16  new_value 16
col 17  new_value 17
col 18  new_value 18

set feedback off

prompt "ADD FILTERING CONDITION"
accept filter
select null "1", null "2", null "3", null "4", null "5", null "6", null "7", null "8", null "9", null "10", null "11", null "12", null "13", null "14", null "15", null "16", null "17", null "18"
from   dual
where  rownum = 0;

   set feedback on

   prompt 1 = &1
   prompt 2 = &2
   prompt 3 = &3
   prompt 4 = &4
   prompt 5 = &5
   prompt 6 = &6
   prompt 7 = &7
   prompt 8 = &8
   prompt 9 = &9
   prompt 10 = &10
   prompt 11 = &11
   prompt 12 = &12
   prompt 13 = &13
   prompt 14 = &14
   prompt 15 = &15
   prompt 16 = &16
   prompt 17 = &17
   prompt 18 = &18
set pause on pages 30 lines 200

prompt "PRESS INTRO FOR NEXT PAGE"


select fecha, &1 &2 &3 &4 &5 &6 &7 &8 &9 &10 &11 &12 &13 &14 &15 &16 &17 &18   from sesmon where &&filter  and sample_id between &&sini and &&sfin order by  sample_id asc;
undef 1
undef 2
undef 3
undef 4
undef 5
undef 6
undef 7
undef 8
undef 9
undef 10
undef 11
undef 12
undef 13
undef 14
undef 15
undef 16
undef 17
undef 18
undef filter
