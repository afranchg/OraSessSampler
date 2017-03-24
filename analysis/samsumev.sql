-- Relationship between a column and the events
-- Example:
-- SQL_IDs related to an event:
-- SQL> @samsumev.sql sql_id CPU

-- SQL_ID               ACT          % SW_EVENT
-- ------------- ---------- ---------- ----------------------------------------------------------------
-- 05nmmw3cs6kmr         54      52.94 On CPU / runqueue
-- 5atyj4wnzsqsv         12      11.76 On CPU / runqueue
-- 87gc466dkhj2h          7       6.86 On CPU / runqueue
-- None                   7       6.86 On CPU / runqueue
-- csuyj957sv3kr          7       6.86 On CPU / runqueue
-- 7jntphb58atyb          5        4.9 On CPU / runqueue
-- 7bfpqwvx7g83p          1        .98 On CPU / runqueue
-- gz29gpg7tdnmr          1        .98 On CPU / runqueue
-- cbkmp45h04akr          1        .98 On CPU / runqueue
-- 3rh3sx5jbr2bn          1        .98 On CPU / runqueue
-- fkz3cyugrm9md          1        .98 On CPU / runqueue
-- 8g3vpj1sgyhgd          1        .98 On CPU / runqueue
-- 4uy8fq989fv3j          1        .98 On CPU / runqueue
-- cm0vyhm5zv04f          1        .98 On CPU / runqueue
-- 9garxcfdhcxrk          1        .98 On CPU / runqueue
-- 24vfkb2n40qw2          1        .98 On CPU / runqueue
-- SQL>
-- The previous output shows that over all the samples with the event On CPU / runqueue, 54 (52,9%) where running sql_id 05nmmw3cs6kmr, etc..
-- we can use another columns and events:
-- @samsumev sid direct path

def columna = &1
def evento = &2

with p as (
select
       count(*) as act,  &&columna,
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
       END , &&columna)
select &&columna, act, round((act*100)/sum(act) over(),2) as "%", sw_event from p where sw_event like '%&&evento%' order by 2 desc
/
undef columna
undef evento