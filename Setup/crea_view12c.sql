-- The view extracts the ACTIVE processes. If you want both active as inactive ones, for some reason, 
-- you can delete the condition:
-- and decode(                                  
--    bitand(s.ksuseidl,11),1,'ACTIVE',0,decode(bitand(s.ksuseflg,4096),0,'INACTIVE','CACHED'),2,'SNIPED',3,'SNIPED', 'KILLED') = 'ACTIVE'

Create or replace view SYS.SIMSES as
select
  sysdate as FECHA,
  s.inst_id as INST_ID,
  s.indx as SID,
  s.ksuseser as "SERIAL#",
  s.ksuudlna as USERNAME,
  decode(                                  
    bitand(s.ksuseidl,11),1,'ACTIVE',0,decode(bitand(s.ksuseflg,4096),0,'INACTIVE','CACHED'),2,'SNIPED',3,'SNIPED', 'KILLED') as STATUS,
  s.ksusemnm as MACHINE,
   s.ksusepnm as PROGRAM,
s.ksusesqi as SQL_ID,
s.ksusepsi as prev_sql_id,
  decode(                                  
    s.ksuseblocker, 4294967295,to_number(null),4294967294,to_number(null), 4294967293,to_number(null), 4294967292,to_number(null),4294967291, to_number(null),bitand(s.ksuseblocker, 2147418112)/65536) as BLOCKING_INSTANCE,
  decode(                                 
    s.ksuseblocker, 4294967295,to_number(null),4294967294,to_number(null), 4294967293,to_number(null), 4294967292,to_number(null),4294967291, to_number(null),bitand(s.ksuseblocker, 65535)) as BLOCKING_SESSION,
   e.kslednam as EVENT,
  w.kslwtp1 as P1,
  w.kslwtp2 as P2,
  w.kslwtp3 as P3,
  decode(
    w.kslwtinwait, 0,decode(bitand(w.kslwtflags,256), 0,-2, decode(round(w.kslwtstime/10000), 0,-1, round(w.kslwtstime/10000))), 0) as WAIT_TIME,
  decode( 
    w.kslwtinwait,0,round((w.kslwtstime+w.kslwtltime)/1000000), round(w.kslwtstime/1000000)) as SECONDS_IN_WAIT,
  decode(
    w.kslwtinwait,1,'WAITING', decode(bitand(w.kslwtflags,256),0,'WAITED UNKNOWN TIME', decode(round(w.kslwtstime/10000),0,'WAITED SHORT TIME', 'WAITED KNOWN TIME'))) as STATE
from
  x$ksuse s,
  x$ksled e,
  x$kslwt w
where
  bitand(s.ksspaflg,1)!=0 and bitand(s.ksuseflg,1)!=0 and s.indx=w.kslwtsid and w.kslwtevt=e.indx
 and  decode(bitand(s.ksuseflg,19),17,'BACKGROUND',1,'USER',2,'RECURSIVE','?') = 'USER' and decode(                                  
    bitand(s.ksuseidl,11),1,'ACTIVE',0,decode(bitand(s.ksuseflg,4096),0,'INACTIVE','CACHED'),2,'SNIPED',3,'SNIPED', 'KILLED') = 'ACTIVE' 
  and s.indx <> (select USERENV('SID') from dual)
 
/

