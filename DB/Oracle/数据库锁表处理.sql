--�����ѯSQL
SELECT object_name, machine, s.sid, s.serial#
FROM gv$locked_object l, dba_objects o, gv$session s
WHERE l.object_id��= o.object_id
AND l.session_id = s.sid; 
--�ͷ�SESSION SQL:
--alter system kill session 'sid, serial#';
ALTER system kill session '485,9083'  ;  

--��ѯOracle����ִ�е�sql��估ִ�и������û�
SELECT b.sid oracleID, b.username "��¼Oracle�û���", b.serial#, spid "����ϵͳID",
       paddr, sql_text "����ִ�е�SQL", b.machine "�������"
  FROM v$process a, v$session b, v$sqlarea c
 WHERE a.addr = b.paddr
   AND b.sql_hash_value = c.hash_value;
   
--�鿴����ִ��sql�ķ����ߵķ��ų���
SELECT A.serial#, OSUSER "���Ե�¼���", PROGRAM "��������ĳ���", USERNAME "��¼ϵͳ���û���",
       SCHEMANAME, B.Cpu_Time "����cpu��ʱ��", STATUS, B.SQL_TEXT "ִ�е�sql"
  FROM V$SESSION A
  LEFT JOIN V$SQL B
    ON A.SQL_ADDRESS = B.ADDRESS
   AND A.SQL_HASH_VALUE = B.HASH_VALUE
 ORDER BY b.cpu_time DESC;
--���oracle��ǰ�ı�������
SELECT l.session_id sid, s.serial#, l.locked_mode "��ģʽ",
       l.oracle_username "��¼�û�", l.os_user_name "��¼�����û���", s.machine "������",
       s.terminal "�ն��û���", o.object_name "����������", s.logon_time "��¼���ݿ�ʱ��"
  FROM v$locked_object l, all_objects o, v$session s
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid
 ORDER BY sid, s.serial#;
--kill����ǰ�����������Ϊ
alter system kill session 'sid , s.serial#'; 
--�ϲ���
SELECT b.sid oracleID, b.username "��¼Oracle�û���", b.serial#, spid "����ϵͳID",
       paddr, sql_text "����ִ�е�SQL", b.machine "�������"
  FROM v$process a, v$session b, v$sqlarea c
 WHERE a.addr = b.paddr
   AND b.sql_hash_value = c.hash_value;
    
SELECT A.serial#, OSUSER "���Ե�¼���", PROGRAM "��������ĳ���", USERNAME "��¼ϵͳ���û���",
       SCHEMANAME, B.Cpu_Time "����cpu��ʱ��", STATUS, B.SQL_TEXT ִ�е�sql
  FROM V$SESSION As
  LEFT JOIN V$SQL B
    ON A.SQL_ADDRESS = B.ADDRESS
   AND A.SQL_HASH_VALUE = B.HASH_VALUE
 ORDER BY b.cpu_time DESC;
    
SELECT l.session_id sid, s.serial#, l.locked_mode "��ģʽ",
       l.oracle_username "��¼�û�", l.os_user_name "��¼�����û���", s.machine "������",
       s.terminal "�ն��û���", o.object_name "����������", s.logon_time "��¼���ݿ�ʱ��"
  FROM v$locked_object l, all_objects o, v$session s
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid
 ORDER BY sid, s.serial#;
 
--1. ORACLE�в鿴��ǰϵͳ��������� 
select * from v$locked_object 
--����ͨ����ѯv$locked_object�õ�sid��objectid��Ȼ����sid��v$session�����ѯ���������ı���v$session�е�objectid�ֶκ�dba_objects��id�ֶι�������ѯ��ϸ�����������

--��ѯSQL���£� 
select sess.sid, 
       sess.serial#, 
       lo.oracle_username, 
       lo.os_user_name, 
       ao.object_name, 
       lo.locked_mode 
  from v$locked_object lo, dba_objects ao, v$session sess, v$process p 
where ao.object_id = lo.object_id 
   and lo.session_id = sess.sid;

--��ѯ��ʲôSQL�����������ԭ��SQL���£� 
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

--2. ORACLE�����ķ��� 
alter system kill session ��146��;  �C146--Ϊ��ס�Ľ��̺ţ���spid


--��ѯ�����ݿ����
select t.*
from v$sqlarea t
where t.SQL_TEXT like 'delete%' and t.FIRST_LOAD_TIME like '2016-11-16%'
order by t.FIRST_LOAD_TIME desc


--ORA-28000: the account is locked-�Ľ���취
ALTER USER ACDEV ACCOUNT UNLOCK;
