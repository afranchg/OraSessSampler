USE IT AT YOUR OWN RISK. IT IS ASSUMED THAT IF YOU USE THIS SCRIPTS, IS UNDER YOUR OWN RESPONSABILITY AND FULL KNOWLEDGE.
THE AUTHOR IS NOT RESPONSIBLE OF ANYTHING RELATED TO THEM. IF YOU DO NOT AGREE WITH THOSE TERMS YOU CANNOT USE THOSE SCRIPTS.

Alfonso M. Franch . Barcelona 2017

This tool is not a substitute for ASH or any Oracle utility. This tool was made to help in the troubleshooting of incidents during a relative short period of time.
Is not thought to be used for long-time monitoring. This tool gives a quick glance, with the option to record it, of all what is happening in the database by sampling
GV$session or related views. I have tried to keep overhead to a minimum.
The tool needs an initial setup, but once ready, can be used against any database only giving him access to it (user and entry in tnsnames.ora)
Although this readme is a bit long, is very detailed. The setup actually is quite straightforward and quick. Do not be afraid!


I provide some scripts to analyze the results. They can be used and modified (same as the tool) to better suit your needs. Also, you can (an actually, will have to) build
your own queries.
The scripts extracts the info of the ACTIVE sessions, excluding the one that performs the sampling.
Inactive sessions are excluded. You can modify easily the tool to change this behaviour (will tell later).
Only USER sessions are monitored. Background processes are excluded.
Shows sessions WAITING or working in CPU.
If output shows no activity, this output is not written to the repository. Only activity in the database is written to the repository. Keep this in mind
if you see time lags between samples.
As said, the sampler is not thought to be a long term or a monitorization tool for multiple databases. So, does not store DBIDs or SIDs of databases. Should be
used to monitor one database at a time. Is not needed (since analysis scripts provide time frame), but recommended truncate the table SESMON when we start
to monitor a new database for another incident.

The idea of the script is taken from Craig Shallahamer's Real Time Session Sampler (OSM Toolkit). Strongly recommend all 
his tools and above all, his lessons and webinars (www.orapub.com). Thank u Craig!

Also, the query I took as the main one is the one suggested by Tanel Poder at http://blog.tanelpoder.com/2008/08/07/the-simplest-query-for-checking-whats-happening-in-a-database/

1. SETUP
 1.1 Prerrequisites:
     - A database that will act as a repository. The space we'll need depends on the activity of the monitored database and the number of samples. We can reserve a 100M tablespace
	 - A schema with quota on this tablespace. In the beginning, should only need CREATE SESSION and CREATE TABLE privileges. Just in case, and as the repository database should not
	   be a Production one, I suggest CONNECT and RESOURCE roles.
	 - In the target database, if is single instance, we have to choices. One, is to sample from GV$SESSION. The other one is to sample from a view. In the second case, the overhead 
	   is less, but need to create a view on SYS schema and a user with SELECT privileges on this view and (I recommend) SELECT_CATALOG_ROLE. In the first case, we'll need a user with 
	   CREATE SESSION and (Recommend) SELECT_CATALOG_ROLE, although SELECT ON GV$SESSION should be enough.
     - The sampler can be run in any server, including our PC or laptop. In the computer which runs the sampler we need:
	   . Python 2 (minimum, 2.4) https://www.python.org/downloads/ (choose the appropiate OS and architecture 32 or 64 bits)
	   . cx_Oracle module for Python https://pypi.python.org/pypi/cx_Oracle (choose the appropiate OS and architecture 32 or 64 bits)
	   . Oracle Client. (can be Instant Client, the basic installation) (http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html)
	   Be careful that the architecture of the three components is the same and matches the one of your OS!
 1.2 Install in repository and target databases:
     - In the database to be monitorized (target), we create a user. The user needs, at least, CREATE SESSION privilege. I recommend also, SELECT_CATALOG_ROLE.
	   Let's call it MONITOR (as an example).
	   CREATE USER MONITOR IDENTIFIED BY <PASSWORD>;
	   GRANT CREATE SESSION TO MONITOR;
	   GRANT SELECT_CATALOG_ROLE TO MONITOR;
	 - If we are in Single instance and are going to use the provided views, for a lesser overhead, first and with the user SYS, we create the view:
	   we run the script that corresponds to the database version we are running (crea_view10g.sql, crea_view11g.sql, crea_view12c.sql).
	   Once successfully executed, we give privileges on the view to the user MONITOR:
	   GRANT SELECT ON SYS.SIMSES TO MONITOR;
	- If we are in a RAC system or do not want to user the views, we just create the user as before and grant him the SELECT privilege on GV$SESSION (or use an already existent user);
	   GRANT SELECT ON GV$SESSION TO MONITOR;
	- In the database that will store the results of the monitor (repository), we create a user with quota on one tablespace with 100M (recommended, not needed). We grant CONNECT and RESOURCE roles to him.
	   Let's call it REPUSER (as an example).
	   CREATE USER REPUSER IDENTIFIED BY <PASSWORD>
	   DEFAULT TABLESPACE <TABLESPACE>
	   TEMPORARY TABLESPACE <TABLESPACE>;
	   ALTER USER REPUSER QUOTA <QUOTA> ON <TABLESPACE>;
	   GRANT CONNECT, RESOURCE TO REPUSER;
	- Now, and in the repository database, we connect as REPUSER and run the script crea_sesmon.sql to create the repository table. The script will ask for the tablespace to store it.
 1.2 Install in Windows and Red Hat Linux for the sampler script.
     - The sampler comes in two versions. Single Instance and RAC. Actually, the difference is in the user of the provided views or the GV$session view for sampling. You can use the
	   RAC script for both RAC as Single Instance databases.
	 - The sampler should run in any computer that has Python 2 (2.4 onwards) and the required modules. Is not tested in Python 3. I will cover the setup in Red Hat Linux and Windows.
	   Another setups should be similar.
	   A. RED HAT LINUX
	    - If you are using RHEL, Python is installed by default. Check that the version is right (2,4 or superior, but 2):
		    [samplerserv].oracle:/home/oracle > python
			Python 2.4.3 (#1, Aug 29 2011, 10:55:55)
			[GCC 4.1.2 20080704 (Red Hat 4.1.2-51)] on linux2
			Type "help", "copyright", "credits" or "license" for more information.
			>>>
		- Download the corresponding module for your version of Python and Oracle from https://pypi.python.org/pypi/cx_Oracle. And follow the provided instructions for setup.
		- Install the Oracle client (you can use the basic package of Instant Client). Download from http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html.
	    - Create (if you do not have) a tnsnames.ora with all the entries for you databases (targets and repository).
		- Be sure that you have the Oracle environment variables in your profile or loaded: ORACLE_HOME, LD_LIBRARY_PATH, SHLIB_PATH and TNS_ADMIN (pointing to the place your tnsnames.ora is).
		  You will need also ORACLE_SID if you want to monitor a local database (one option).
		- you can check that the python module is correctly installed doing:
		    [samplerserv].oracle:/home/oracle > python
			Python 2.4.3 (#1, Aug 29 2011, 10:55:55)
			[GCC 4.1.2 20080704 (Red Hat 4.1.2-51)] on linux2
			Type "help", "copyright", "credits" or "license" for more information.
			>>> import cx_Oracle
			>>>
		  Beware of the uppercase and lowercase. Python is case sensitive (both in Unix as Windows).
		  Should not return any message.
		- Now, edit the sampler script and look for the lines that read:
		  usconr = 'usuario/password' (this is the repository connection)
		  uscont = 'usuario/password' (this is the target connection)
		  Put the rights user and password.
		  Check that the first line of the script ("shebang"), points to the right path of python. 
		- Change permissions to the script to make it executable
		- The script now is ready for use.
	   B. Windows
		- We download the Windows version for Python from https://www.python.org/downloads/ and the cx_Oracle module and the Instant Client (if needed) from the already mentioned sites.
		- Be sure that all the binaries are for the same architecture! (32 o 64 bits). Do not mix them.
		- Windows setup is trickier than RHEL's. Once installed the Oracle Client, add the variable ORACLE_HOME to the Windows environment: (here you are an example:http://www.computerhope.com/issues/ch000549.htm)
		- Add also the ORACLE_HOME's path to the variable PATH of Windows.
		- I recommend to restart the computer now.
		- Now, install Python. I would recommend to restart the computer also after installing it.
		- Finally, install the module with the provided installer. After the installation, I recommend you restart again the computer.
		- Now check the PATH environment variable. Should be similar to this:
			C:\ProgramData\Oracle\Java\javapath;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;
			C:\Program Files (x86)\Microsoft Application Virtualization Client;C:\instantclient_11_2;C:\Python27;C:\Python27\Lib\site-packages
			Is very important that the ORACLE_HOME is before the Python directory. The shown order works.
		-Now, you can launch cmd.exe and try the python setup as we did for Red Hat.
		- To launch the script we'll need to use a bat script. You have a working example in the folder "Windows" of the sampler zip file. Modify it according to your needs.

2. Launching the sampler script
	- The script, if executed without parameters, returns the use instructions.
	- To end the sampling, use Control + C.
	- There are two modes, local (for a local database) and remote (for both local as remote)
	- Local mode:
		./session_sampler.py -l y -i <interval in secs>
		Quite straight forward. To be run in a local database as SYSDBA.You need ORACLE_SID environment variable and be logged on the system as oracle owner user,
		-l y indicates that the connection is local
		-i <interval in secs> provide an interval for sampling in seconds. Any number from 1 onwards. No decimals.
		Example:
		./session_sampler.py -l y -i 1
		
		Runs a sample every second, until you interrupt with Control + C in local mode. 
		When run locally, you do not need the repository or setup the connections. Just log in as oracle user and run the sampler. Will not store data.
		
	- Remote mode:
		./session_sampler.py -o <n|y|p> -i <interval in secs> -r <SID Repository> -t <SID target>
		-o <n|y|p>. -o means output. Three options:
		            -o n  To be run in background. Do not shows output in screen and stores the collected data in the repository.
					-o y  Shows output in screen and stores the retrieved data in the repository for posterior analysis.
					-o p  Shows only data in screen. It requires a connection to the repository, but does not write any data in it.
					
		-i <interval in secs> provide an interval for sampling in seconds. Any number from 1 onwards. No decimals.
		
		-r	<SID Repository>  Name of the repository database as stated in tnsnames.ora
		
		-t <SID target> Name of the target database as stated in tnsnames.ora
		
		Examples:
		- Normal execution (Real Time):
		  We monitor the database TARG storing the retrieved data in the database REPOS. Sampling each 5 secs and show results in screen. (and stores results in REPOS)
			./session_sampler.py -o y -i 5 -r REPOS -t TARG
		
		- Running in background (UNIX):
		  We monitor the database TARG storing the retrieved data in database REPOS. Sampling each second. Does not show output in the screen and we can disconnect from our session.
		  nohup $PWD/session_sampler.py -o n -i 1 -r REPOS -t TARG &
		  
		  To end the process:
		  We search the process PID using ps:
		    [samplerserv].oracle:/home/oracle > ps -ef | grep sample
			 oracle   18728  4485  1 11:44 pts/0    00:00:00 /usr/bin/python /home/oracle/session_sampler.py -o n -i 1 -r REPOS -t TARG
			 oracle   18732  4485  0 11:44 pts/0    00:00:00 grep sample
			[samplerserv].oracle:/home/oracle > kill -9 18728
			[samplerserv].oracle:/home/oracle >
			 [1]+  Killed                  nohup $PWD/session_sampler.py -o n -i 1 -r REPOS -t TARG
			[samplerserv].oracle:/home/oracle >
			[samplerserv].oracle:/home/oracle >
			[samplerserv].oracle:/home/oracle > ps -ef | grep sample
			 oracle   18739  4485  0 11:44 pts/0    00:00:00 grep sample
			[samplerserv].oracle:/home/oracle >
			
		- Screen output only :
		  We monitor the database TARG, sampling each second. Do not store the results in the repository. Notice that we need the connection to the repository database, even
		  when do not store data.
		  ./session_sampler.py -o p -i 1 -r REPOS -t TARG

3. Analysis of results.
	In real time, you can see the output in the screen. The output shows only the most relevant fields, translating which processes are waiting and which ones running on CPU.
    In the table SESMON stored more data in raw format (data from gv$session). You can query it in different ways to get the picture of what is happenning. 
    Enclosed are five scripts that will help in the task. Of course, you can modify them or use your own queries. 
    The tools provides a first approach to an incident. So perhaps with the data retrieved, you will be able to solve it, but perhaps you will need to collect additional data. Is a 
    first diagnostic tool.
	Those are the provided scripts. Instructions and examples are provided in each one. Feel free to play with them and try different options:
	- samdef.sql. This is the first script you must run. It establishes the time frame for the analysis of the data.
	- samres.sql. This script extracts a summary in terms of percentage related to a column and all the samples.
	- samsumcol.sql. Summary of events in percentage related to a column total samples for this column
	- samsumev.sql. Relationship between a column and the events.
	- samtl.sql Extracts the time line of the introduced columns with a filter condition.



