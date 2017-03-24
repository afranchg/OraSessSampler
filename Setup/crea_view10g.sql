-- The view extracts the ACTIVE processes. If you want both active as inactive ones, for some reason, 
-- you can delete the condition:
-- and decode(                                  
--    bitand(s.ksuseidl,11),1,'ACTIVE',0,decode(bitand(s.ksuseflg,4096),0,'INACTIVE','CACHED'),2,'SNIPED',3,'SNIPED', 'KILLED') = 'ACTIVE'

Create or replace view SYS.SIMSES as  select
SYSDATE as FECHA,
s.inst_id               as INST_ID,
s.indx                   as SID ,
s.ksuseser               as SERIAL# ,
s.ksuudlna               as USERNAME ,
decode                   
  (bitand (s.ksuseidl, 11), 1, 'ACTIVE', 0, decode (bitand (s.ksuseflg, 4096), 0, 'INACTIVE', 'CACHED'), 2, 'SNIPED', 3, 'SNIPED', 'KILLED') as STATUS,
s.ksusemnm               as MACHINE ,
s.ksusepnm               as PROGRAM ,
s.ksusesqi               as SQL_ID ,
s.ksusepsi	             as PREV_SQL_ID, 
NULL                     as BLOCKING_INSTANCE, 
decode                    
  (s.ksuseblocker, 4294967295, to_number (null), 4294967294, to_number (null), 4294967293, to_number (null), 4294967292, to_number (null), 4294967291, to_number (null), s.ksuseblocker) as BLOCKING_SESSION,
e.kslednam               as EVENT ,
s.ksusep1                as P1 ,
s.ksusep2                as P2 ,
s.ksusep3                as P3 ,
decode                    
  (s.ksusetim, 0, 0, -1, -1, -2, -2, decode (round (s.ksusetim/10000), 0, -1, round (s.ksusetim/10000))) as WAIT_TIME,
s.ksusewtm               as SECONDS_IN_WAIT ,
decode                  
  (s.ksusetim, 0, 'WAITING', -2, 'WAITED UNKNOWN TIME', -1, 'WAITED SHORT TIME', decode (round (s.ksusetim/10000), 0, 'WAITED SHORT TIME', 'WAITED KNOWN TIME'))  as STATE
from
x$ksuse s,
x$ksled e
where
bitand (s.ksspaflg, 1) !=0 and bitand (s.ksuseflg, 1) !=0 and s.ksuseopc=e.indx and decode(bitand(s.ksuseflg,19), 17,'BACKGROUND', 1,'USER', 2,'RECURSIVE','?') = 'USER'
and decode (bitand (s.ksuseidl, 11), 1, 'ACTIVE', 0, decode (bitand (s.ksuseflg, 4096), 0, 'INACTIVE', 'CACHED'), 2, 'SNIPED', 3, 'SNIPED', 'KILLED') = 'ACTIVE' 
   and s.indx <> (select USERENV('SID') from dual)

/


