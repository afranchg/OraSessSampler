create table SESMON(
 SAMPLE_ID                                          NUMBER,
 FECHA                                              DATE,
 INST_ID                                            NUMBER,
 SID                                                NUMBER,
 SERIAL#                                            NUMBER,
 USERNAME                                           VARCHAR2(30),
 STATUS                                             VARCHAR2(8),
 MACHINE                                            VARCHAR2(64),
 PROGRAM                                            VARCHAR2(48),
 SQL_ID                                             VARCHAR2(13),
 PREV_SQL_ID	                                  VARCHAR2(13),
 BLOCKING_INSTANCE                                  NUMBER,
 BLOCKING_SESSION                                   NUMBER,
 EVENT                                              VARCHAR2(64),
 P1                                                 NUMBER,
 P2                                                 NUMBER,
 P3                                                 NUMBER,
 WAIT_TIME                                          NUMBER,
 SECONDS_IN_WAIT                                    NUMBER,
 STATE                                              VARCHAR2(19)
) tablespace &tablespace
