--锁表查询SQL
SELECT object_name, machine, s.sid, s.serial#
FROM gv$locked_object l, dba_objects o, gv$session s
WHERE l.object_id　= o.object_id
AND l.session_id = s.sid; 
--释放SESSION SQL:
--alter system kill session 'sid, serial#';
ALTER system kill session '485,9083'  ;  

--查询Oracle正在执行的sql语句及执行该语句的用户
SELECT b.sid oracleID, b.username "登录Oracle用户名", b.serial#, spid "操作系统ID",
       paddr, sql_text "正在执行的SQL", b.machine "计算机名"
  FROM v$process a, v$session b, v$sqlarea c
 WHERE a.addr = b.paddr
   AND b.sql_hash_value = c.hash_value;
   
--查看正在执行sql的发起者的发放程序
SELECT A.serial#, OSUSER "电脑登录身份", PROGRAM "发起请求的程序", USERNAME "登录系统的用户名",
       SCHEMANAME, B.Cpu_Time "花费cpu的时间", STATUS, B.SQL_TEXT "执行的sql"
  FROM V$SESSION A
  LEFT JOIN V$SQL B
    ON A.SQL_ADDRESS = B.ADDRESS
   AND A.SQL_HASH_VALUE = B.HASH_VALUE
 ORDER BY b.cpu_time DESC;
--查出oracle当前的被锁对象
SELECT l.session_id sid, s.serial#, l.locked_mode "锁模式",
       l.oracle_username "登录用户", l.os_user_name "登录机器用户名", s.machine "机器名",
       s.terminal "终端用户名", o.object_name "被锁对象名", s.logon_time "登录数据库时间"
  FROM v$locked_object l, all_objects o, v$session s
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid
 ORDER BY sid, s.serial#;
--kill掉当前的锁对象可以为
alter system kill session 'sid , s.serial#'; 
--合并的
SELECT b.sid oracleID, b.username "登录Oracle用户名", b.serial#, spid "操作系统ID",
       paddr, sql_text "正在执行的SQL", b.machine "计算机名"
  FROM v$process a, v$session b, v$sqlarea c
 WHERE a.addr = b.paddr
   AND b.sql_hash_value = c.hash_value;
    
SELECT A.serial#, OSUSER "电脑登录身份", PROGRAM "发起请求的程序", USERNAME "登录系统的用户名",
       SCHEMANAME, B.Cpu_Time "花费cpu的时间", STATUS, B.SQL_TEXT 执行的sql
  FROM V$SESSION As
  LEFT JOIN V$SQL B
    ON A.SQL_ADDRESS = B.ADDRESS
   AND A.SQL_HASH_VALUE = B.HASH_VALUE
 ORDER BY b.cpu_time DESC;
    
SELECT l.session_id sid, s.serial#, l.locked_mode "锁模式",
       l.oracle_username "登录用户", l.os_user_name "登录机器用户名", s.machine "机器名",
       s.terminal "终端用户名", o.object_name "被锁对象名", s.logon_time "登录数据库时间"
  FROM v$locked_object l, all_objects o, v$session s
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid
 ORDER BY sid, s.serial#;
 
--1. ORACLE中查看当前系统中锁表情况 
select * from v$locked_object 
--可以通过查询v$locked_object拿到sid和objectid，然后用sid和v$session链表查询是哪里锁的表，用v$session中的objectid字段和dba_objects的id字段关联，查询详细的锁表情况。

--查询SQL如下： 
select sess.sid, 
       sess.serial#, 
       lo.oracle_username, 
       lo.os_user_name, 
       ao.object_name, 
       lo.locked_mode 
  from v$locked_object lo, dba_objects ao, v$session sess, v$process p 
where ao.object_id = lo.object_id 
   and lo.session_id = sess.sid;

--查询是什么SQL引起了锁表的原因，SQL如下： 
select l.session_id sid, 
       s.serial#, 
       l.locked_mode, 
       l.oracle_username, 
       s.user#, 
       l.os_user_name, 
       s.machine, 
       s.terminal, 
       a.sql_text, 
       a.action 
  from v$sqlarea a, v$session s, v$locked_object l 
where l.session_id = s.sid 
   and s.prev_sql_addr = a.address 
order by sid, s.serial#;

--2. ORACLE解锁的方法 
alter system kill session ’146′;  –146--为锁住的进程号，即spid


--查询对数据库操作
select t.*
from v$sqlarea t
where t.SQL_TEXT like 'delete%' and t.FIRST_LOAD_TIME like '2016-11-16%'
order by t.FIRST_LOAD_TIME desc


--ORA-28000: the account is locked-的解决办法
ALTER USER ACDEV ACCOUNT UNLOCK;
