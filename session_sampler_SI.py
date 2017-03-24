#!/usr/bin/python
import os
import sys
import time
from datetime import datetime
import getopt
import cx_Oracle
#if 'ORACLE_HOME' not in os.environ.keys():
#    os.environ['ORACLE_HOME'] = '/oracle/product/12.1.0.2/database'
#if 'LD_LIBRARY_PATH' not in os.environ.keys():
#    os.environ['LD_LIBRARY_PATH'] = os.environ['ORACLE_HOME'] + '/lib'
#if '/usr/lib/oracle' not in os.environ['PATH']:
#    os.environ['PATH'] = os.environ['ORACLE_HOME'] + '/bin:' + os.environ['PATH']
#if 'ORACLE_SID' not in os.environ.keys():
#    os.environ['ORACLE_SID'] = 'xx'

# Deben configurarse aqui los usuarios y passwords para la conexion
# Conexion al repositorio:
usconr = 'user/password'
uscont = 'user/password'

def usage():
 print('Uso: %s -o <n|y|p> -i <intervalo en segs> -r <SID Repositorio> -t <SID target>' % (sys.argv[0]))
 print 'o'
 print('Uso: %s -l y -i <intervalo en segs>' % (sys.argv[0]))

if len(sys.argv[1:]) == 0:
    usage()
    sys.exit(2)
try:
#    opts, args = getopt.getopt(sys.argv[1:], 'd:o:i:h')
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:t:r:l:h')
except getopt.GetoptError:
    usage()
    sys.exit(2)

for opt, arg in opts:
    if opt in ('-h'):
        usage()
        sys.exit(2)
#    elif opt in ('-d'):
#        dblin = arg
    elif opt in ('-o'):
        outp = arg
    elif opt in ('-i'):
        intv = int(arg)
    elif opt in ('-r'):
         repos = arg
    elif opt in ('-t'):
         target = arg
    elif opt in ('-l'):
         lcv = arg
    else:
        usage()
        sys.exit(2)


if (intv == 0):
   print
   print ('EL INTERVALO DEBE SER SUPERIOR A 0 Y NO DECIMAL')
   print
   usage()
   sys.exit(2)
if 'lcv' not in locals():

 try:
  # 
  strcont = uscont + '@' + target
  strconr  = usconr + '@' + repos
  conr = cx_Oracle.connect(strconr)
# 
  cont = cx_Oracle.connect(strcont)
# Creamos cursor para verificar el ultimo sample id de la tabla de monitorizacion
  sam = conr.cursor()
  sam.execute("select decode(max(sample_id),null,1,max(sample_id)+1) from sesmon")
  sample = sam.fetchone()[0]
  sam.close()
  while True:
# Para no output por pantalla y guardar datos. Modo en background
    if (outp == 'n'):
        stmttrg = "select :mues, fecha, inst_id, sid, serial#, username, status, machine, program, sql_id, prev_sql_id, decode(blocking_instance,NULL,'NULL',blocking_instance), decode(blocking_session,null,'NULL',blocking_session), event, p1, p2, p3, wait_time, seconds_in_wait, state from dual,SYS.SIMSES"
        targ = cont.cursor()
        monc = conr.cursor()
        targ.execute(stmttrg, mues = sample)
        rest = targ.fetchall()
        for elem in rest:
           stmtmon = 'insert into sesmon values(' + str(elem[0]) + ',' + 'to_date(\'' + str(elem[1]) + '\',\'YYYY-MM-DD HH24:MI:SS\'),' +  str(elem[2]) + ',' + str(elem[3]) +  ',' +  str(elem[4]) + ','  + '\'' + str(elem[5]) +  '\''  +  ',' + '\'' + str(elem[6]) +  '\''  +  ',' + '\'' + str(elem[7]) +  '\''  +  ',' + '\'' + str(elem[8]) +  '\''  +  ',' + '\'' + str(elem[9]) +  '\''  +  ',' +  '\'' + str(elem[10]) + '\'' +  ',' +  str(elem[11]) +  ',' +  str(elem[12]) +   ',' + '\'' +  str(elem[13]) + '\'' +  ',' +  str(elem[14]) +  ',' +  str(elem[15]) +  ',' +  str(elem[16]) +  ',' + str(elem[17]) +  ',' +  str(elem[18]) + ',' +  '\''  + str(elem[19])  + '\'' + ')'
           #stmtmon = 'insert into sesmon values(' + str(elem[0]) + ',' + 'to_date(\'' + str(elem[1]) + '\',\'YYYY-MM-DD HH24:MI:SS\'),' +  str(elem[2]) + ',' + str(elem[3]) +  ',' +  str(elem[4]) + ','  + '\'' + str(elem[5]) +  '\''  +  ',' + '\'' + str(elem[6]) +  '\''  +  ',' + '\'' + str(elem[7]) +  '\''  +  ',' + '\'' + str(elem[8]) +  '\''  +  ',' + '\'' + str(elem[9]) +  '\''  +  ',' +  str(elem[10]) +  ',' +  str(elem[11]) +  ',' + '\'' + str(elem[12]) +  '\''  +  ',' +  str(elem[13]) +  ',' +  str(elem[14]) +  ',' +  str(elem[15]) +  ',' +  str(elem[16]) +  ',' + str(elem[17]) +  ',' + '\'' + str(elem[18]) +  '\''  + + str(elem[19]) +  '\'' + ')'
           monc.execute(stmtmon)
        monc.close()
        targ.close()
        conr.commit()
        sample += 1
        time.sleep(intv)
##  Si queremos solo output por pantalla y no guardar datos conexion remota y vista creada
    elif (outp == 'p'):
       stmttrg = "select :mues, fecha, inst_id, sid, serial#, username, status, machine, program, sql_id, decode(blocking_instance,NULL,'NULL',blocking_instance), decode(blocking_session,null,'NULL',blocking_session), event, p1, p2, p3, wait_time, seconds_in_wait, state from dual,SYS.SIMSES"
       print("BD Monitorizada: %s" % target)
       targ = cont.cursor()
       targ.execute(stmttrg, mues = sample)
       rest = targ.fetchall()
       print("%-19s | %-6s | %-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ("Fecha","InsNum","SID", "Evento", "Usuario", "Estado", "Descripcion", "SQL_ID", "BLKIN", "BLKSES"))
       for elem in rest:
           if (elem[18] != 'WAITING'):
              estado = 'WORKING'
              event = 'On CPU / runqueue'
           else:
               estado = 'WAITING'
               event =  elem[12]
           print("%-19s | %-6s | %-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ( elem[1], elem[2], elem[3], event , elem[5], elem[6], estado , elem[9], elem[10], elem[11]))
       targ.close()
       sample += 1
       time.sleep(intv)
       print
       print
##  Si queremos output por pantalla  guardar datos
    elif (outp == 'y'):
       stmttrg = "select :mues, fecha, inst_id, sid, serial#, username, status, machine, program, sql_id, prev_sql_id, decode(blocking_instance,NULL,'NULL',blocking_instance), decode(blocking_session,null,'NULL',blocking_session), event, p1, p2, p3, wait_time, seconds_in_wait, state from dual,SYS.SIMSES"
       print("BD Monitorizada: %s" % target)
       print ("Sample_id: %s " % sample)
       targ = cont.cursor()
       monc = conr.cursor()
       targ.execute(stmttrg, mues = sample)
       rest = targ.fetchall()
       print("%-19s | %-6s | %-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ("Fecha","InsNum","SID", "Evento", "Usuario", "Estado", "Descripcion", "SQL_ID", "BLKIN", "BLKSES"))
       for elem in rest:
           stmtmon = 'insert into sesmon values(' + str(elem[0]) + ',' + 'to_date(\'' + str(elem[1]) + '\',\'YYYY-MM-DD HH24:MI:SS\'),' +  str(elem[2]) + ',' + str(elem[3]) +  ',' +  str(elem[4]) + ','  + '\'' + str(elem[5]) +  '\''  +  ',' + '\'' + str(elem[6]) +  '\''  +  ',' + '\'' + str(elem[7]) +  '\''  +  ',' + '\'' + str(elem[8]) +  '\''  +  ',' + '\'' + str(elem[9]) +  '\''  +  ',' +  '\'' + str(elem[10]) + '\'' +  ',' +  str(elem[11]) +  ',' +  str(elem[12]) +  ',' + '\'' +  str(elem[13]) + '\'' +  ',' +  str(elem[14]) +  ',' +  str(elem[15]) +  ',' +  str(elem[16]) +  ',' + str(elem[17]) +  ',' +  str(elem[18]) + ',' +  '\''  + str(elem[19])  + '\'' + ')'
           if (elem[19] != 'WAITING'):
              estado = 'WORKING'
              event = 'On CPU / runqueue'
           else:
               estado = 'WAITING'
               event =  elem[13]
           print("%-19s | %-6s | %-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ( elem[1], elem[2], elem[3], event , elem[5], elem[6], estado , elem[9], elem[11], elem[12]))
           monc.execute(stmtmon)
#  sam.close()
       targ.close()
       conr.commit()
       monc.close
       sample += 1
       time.sleep(intv)
       print
       print
    else:
       usage()
       break
 except KeyboardInterrupt:
        print("Ejecucion interrumpida por el usuario")
 except NameError:
        usage()
# Aqui ponemos la conexion local
else:
  if (lcv == 'y'):
    con = cx_Oracle.Connection(mode = cx_Oracle.SYSDBA)
    dbmon = os.environ['ORACLE_SID']
    try:
        while True:
          sam = con.cursor()
          sam.execute("select  sid, CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue' ELSE event END as Event, username, status, CASE WHEN state != 'WAITING' THEN 'WORKING' ELSE 'WAITING' END AS state, sql_id , blocking_session, blocking_instance from v$session where type = 'USER' and sid <> (select USERENV('SID') from dual) and status = 'ACTIVE'")
          sample = sam.fetchall()
          print("BD Monitorizada: %s" % dbmon)
          print("%-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ("SID", "Evento", "Usuario", "Estado", "Descripcion", "SQL_ID", "BLKIN", "BLKSES"))
          for elem in sample:
              print("%-5s | %-30s | %-20s | %-12s | %-12s | %-15s | %-8s | %-5s " % ( elem[0], elem[1], elem[2], elem[3], elem[4], elem[5], elem[6], elem[7]))
          sam.close()
          print
          print
          time.sleep(intv)
    except KeyboardInterrupt:
        print("Ejecucion interrumpida por el usuario")
  else:
    usage()
    sys.exit(2)

