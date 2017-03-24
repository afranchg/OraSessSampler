@echo off
set TNS_ADMIN=C:\instantclient_11_2
set ORACLE_HOME=C:\instantclient_11_2
set PATH=C:\ProgramData\Oracle\Java\javapath;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\Microsoft Application Virtualization Client;C:\instantclient_11_2;C:\Python27;C:\Python27\Lib\site-packages
set /p nomb="Enter TNSnames string: "
set /p outp="Enter ouput option (p|y|n): "
start /max C:\Windows\System32\cmd.exe /k python C:\Users\afranchg\Desktop\session_samplerRAc.py -o %outp% -i 1 -r REPOS -t %nomb%