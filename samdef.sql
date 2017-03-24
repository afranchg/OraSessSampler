-- This script defines the time frame where will take place the searches in the table SESMON.
-- Is the first one to be executed and must be executed whenever we want to change the time frame.

undefine sini
undefine sfin
undefine fecha_ini
undefine fecha_fin
alter session set nls_date_format='dd-mm-yy hh24:mi:ss';
prompt "-------------------"
prompt "AVAILABLE PERIOD:"
prompt "-------------------"
select min(sample_id) "Lower Sample", min(fecha) "Lower Date", max(sample_id) "Higher Sample" , max(fecha) "Higher Date" from sesmon;
set serveroutput on
prompt "INTRODUCE THE LOWER DATE YOU WANT TO START YOUR SEARCH FROM (FORMAT: DD-MM-YY HH24:MI:SS):"
ACCEPT fecha_ini
prompt "INTRODUCE THE HIGHER DATE YOU WANT TO SEARCH UNTIL (FORMAT: DD-MM-YY HH24:MI:SS):"
accept fecha_fin

set verify off
set feedback off
prompt "---------------------------------"
prompt "THE TIME FRAME FOR THE SEARCH IS:"
prompt "---------------------------------"
column min(sample_id) NEW_VALUE sini
column max(sample_id) NEW_VALUE sfin
select min(sample_id), min(fecha), max(sample_id), max(fecha) from sesmon where fecha between to_date('&fecha_ini','DD-MM-YY HH24:MI:SS') and to_date('&fecha_fin','DD-MM-YY HH24:MI:SS');
prompt