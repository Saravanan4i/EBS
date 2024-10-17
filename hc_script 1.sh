################################################################################################################################
######******************** Oracle Database Health Check ******************#################
################################################################################################################################
#!/bin/sh

. /u01/app/oracle/product/19.0.0.0/dbhome_1/PRODCDB_sesdbprod.env
DATE1=$(date +"%d-%m-%y")
date=`date +"%d_%b_%y"`
LOGFILE=/home/oracle/HC/SIIX_SLOVAKIA_DB_Health_check_status_$date.html
LOGERROR_DB=/home/oracle/HC/"$ORACLE_SID"_Health_DB_Error_$date.log
LOGERROR_LSNR=/home/oracle/HC/"$ORACLE_SID"_Health_LSNR_Error_$date.log
LOGERROR_DB_RMAN=/home/oracle/HC/"$ORACLE_SID"_Health_RMAN_Error_$date.log
parm_error_log=/home/oracle/HC/parm_error.log
process()
{
if [ -f "$1" ]
then
echo "Processing"
else
echo "">$parm_error_log
exit 1
fi
}
#process /home/oracle/HC/tmperr
echo "<!DOCTYPE html>"
echo "<html>"
echo "<body>"
echo "Content-type: text/css"
echo "<p style=text-align:right;>Information generated on `date` </p>" > $LOGFILE
echo "<html><head><title>SIIX SLOVAKIA Oracle Database Health Check" >> $LOGFILE
echo "</title></head><body>" >> $LOGFILE
echo "<style> h1 {color:green;text-decoration: underline;} </style> <h1 align="center">Database Health Check - PROD - 19.22.0.0.0</h1>" >> $LOGFILE
echo "" >> $LOGFILE
echo "" >> $LOGFILE
echo "<style> h2 {color:maroon;text-decoration: underline;} </style> <h2 align="left"> SYSTEM STATUS - Linux </h2>" >> $LOGFILE
echo "<style> h4 {color:blue;text-decoration: underline;} </style> <h4 align="left"> `hostname`: </h2>" >> $LOGFILE
echo "" >> $LOGFILE
echo "<h3>Disk Info:</h3>" >> $LOGFILE
echo "<table>" >> $LOGFILE
echo "<td>" >> $LOGFILE
echo "<pre> `df -h` </pre>" >> $LOGFILE
echo "</td>" >> $LOGFILE
echo "</table>" >> $LOGFILE
echo "" >> $LOGFILE
echo "<h3>Current CPU Usage:</h3>" >> $LOGFILE
echo "<table>" >> $LOGFILE
echo "<td>" >> $LOGFILE
echo "<pre> `sar -u 1 1` </pre>" >> $LOGFILE
echo "</td>" >> $LOGFILE
echo "</table>" >> $LOGFILE
echo "" >> $LOGFILE
echo "<h3>Current Memory Usage:</h3>" >> $LOGFILE
echo "<table>" >> $LOGFILE
echo "<td>" >> $LOGFILE
echo "<pre> `free -g` </pre>" >> $LOGFILE
echo "</td>" >> $LOGFILE
echo "</table>" >> $LOGFILE
echo "" >> $LOGFILE
echo "" >> $LOGFILE
LSNR_UP=`ps -ef|grep -w "tnslsnr PROD"|grep -v grep |wc -l`;
lsnr_num=`expr $LSNR_UP`
if [ $lsnr_num -eq 0 ]
then
echo "<h2> Listener Status - PROD - <mark>UP</mark> </h2>" >> $LOGFILE
echo "<table>" >> $LOGFILE
echo "<td><pre> `$ORACLE_HOME/bin/lsnrctl status $ORACLE_SID` </pre></td>" >> $LOGFILE
echo "</table>" >> $LOGFILE
else [ $lsnr_num -lt 1 ]
echo "Listener is Down - PROD " > $LOGERROR_LSNR
$ORACLE_HOME/bin/lsnrctl status $ORACLE_SID >> $LOGFILE
echo `ls -ltr $LOGERROR_LSNR`
cat $LOGERROR_LSNR | mailx -s "Listener - PROD is down. Please check!" sasikumar.d@4iapps.com
fi
echo "" >> $LOGFILE
echo "<style> h2 {color:maroon;text-decoration: underline;} </style> <h2 align="left"> <h2> DATABASE STATUS - PROD </h2>" >> $LOGFILE
echo "" >> $LOGFILE
check_stat=`ps -ef|grep $ORACLE_SID|grep pmon|wc -l`;
oracle_num=`expr $check_stat`
if [ $oracle_num -eq 1 ]
then
echo "connecting DB"
$ORACLE_HOME/bin/sqlplus -s /nolog<<ENDINP > /home/oracle/HC/"$ORACLE_SID"_Health_DB_Status_$date.log
connect / as sysdba
set lines 300 pages 300
SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><h3><left>Database is up</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_DB_info.out
SELECT 
    gi.host_name,
    gi.instance_name,
    db.dbid,
    db.name AS database_name,
    db.open_mode,
    db.log_mode
FROM 
    gv\$instance gi,
    v\$database db
UNION ALL
SELECT 
    gi.host_name,
    gi.instance_name,
    pdb.con_id,
    pdb.name AS pdb_name,
    pdb.open_mode,
    db.log_mode
FROM 
    gv\$instance gi,
    v\$database db,
    v\$pdbs pdb;
spool off;
exit;
ENDINP
else [ $oracle_num -lt 1 ]
echo "PMON process not found" > $LOGERROR_DB
echo "Trying to connect to DB for errors. Please check log file $LOGERROR_DB"
$ORACLE_HOME/bin/sqlplus -s /nolog<<ENDINP >> $LOGERROR_DB
connect / as sysdba
show user;
set lines 300 pages 300
select host_name,instance_name,dbid,name,open_mode,log_mode from v\$instance,v\$database;
exit;
ENDINP
check_err_stat=`cat $LOGERROR_DB |grep ORA-|wc -l`;
oracle_err_num=`expr $check_err_stat`
if [ $oracle_err_num -gt 0 ]
then
echo `ls -ltr $LOGERROR_DB`
cat $LOGERROR_DB | mailx -s "Database $ORACLE_SID is down. Please check!" vikas.b@4iapps.com
exit 1
fi
fi
cat /home/oracle/HC/"$ORACLE_SID"_Health_DB_Status_$date.log >> $LOGFILE
echo "Database Current Details"
$ORACLE_HOME/bin/sqlplus -s /nolog <<ENDINP > /home/oracle/HC/"$ORACLE_SID"_Health_DB_curr_status.out
connect / as sysdba
alter session set container=SESPROD;
show user;
set lines 300 pages 300
set heading on

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><br><br><br><h3><left>Database Physical Size</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_1.out
SELECT (SUM (BYTES / (1014*1024*1024))) "PHYSICAL_SIZE(GB)" FROM dba_data_files;
spool off;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><h3><left>ASM Diskgroup Details</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_2.out
SELECT name, total_mb, free_mb, state FROM v\$asm_diskgroup;
spool off;
SET MARKUP HTML OFF;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><br><br><h3><left>Database Logical Size</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_3.out
SELECT "PHYSICAL_SIZE(GB)" - "FREE_SPACE(GB)" "LOGICAL_SIZE(GB)"
FROM (SELECT (SELECT (SUM (BYTES / (1024*1024*1024 )))
FROM dba_data_files) "PHYSICAL_SIZE(GB)", (SELECT (SUM (BYTES / (1024*1024*1024 )))
FROM dba_free_space) "FREE_SPACE(GB)"
FROM DUAL);
spool off;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><h3>Tablespaces Used Percentage</h3> -
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "width='70%' border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_4.out
set feedback off echo off
select a.tablespace_name,
       a.bytes_alloc/(1024*1024) "TOTAL ALLOC (MB)",
       a.physical_bytes/(1024*1024) "TOTAL PHYS ALLOC (MB)",
       nvl(b.tot_used,0)/(1024*1024) "USED (MB)",
       (nvl(b.tot_used,0)/a.bytes_alloc)*100 "% USED"
from ( select tablespace_name,
       sum(bytes) physical_bytes,
       sum(decode(autoextensible,'NO',bytes,'YES',maxbytes)) bytes_alloc
       from dba_data_files
       group by tablespace_name ) a,
     ( select tablespace_name, sum(bytes) tot_used
       from dba_segments
       group by tablespace_name ) b
where a.tablespace_name = b.tablespace_name (+)
--and   (nvl(b.tot_used,0)/a.bytes_alloc)*100 > 10
and   a.tablespace_name not in (select distinct tablespace_name from dba_temp_files)
and   a.tablespace_name not like 'UNDO%'
order by 5 desc;
spool off;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><h3>Temporary Tablespace Usage</h3> -
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_5.out
SELECT
   A.tablespace_name tablespace,
   D.mb_total,
   SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
   D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM
   v\$sort_segment A,
(
SELECT
   B.name,
   C.block_size,
   SUM (C.bytes) / 1024 / 1024 mb_total
FROM
   sys.v\$tablespace B,
   sys.v\$tempfile C
WHERE
   B.ts#= C.ts#
GROUP BY
   B.name,
   C.block_size
) D
WHERE
   A.tablespace_name = D.name
GROUP by
   A.tablespace_name,
   D.mb_total
/
spool off;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><br><br><br><br><h3>UNDO Tablespace Usage</h3> -
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_6.out
SELECT d.tablespace_name, round(((NVL(f.bytes,0) + (a.maxbytes - a.bytes))/1048576+ u.exp_space),2)
as max_free_mb, round(((a.bytes - (NVL(f.bytes,0)+ (1024*1024*u.exp_space)))*100/a.maxbytes),2)
used_pct FROM   sys.dba_tablespaces d, (select tablespace_name, sum(bytes) bytes,
sum(greatest(maxbytes,bytes)) maxbytes from sys.dba_data_files group by tablespace_name) a,
(select tablespace_name, sum(bytes) bytes from sys.dba_free_space group by tablespace_name) f ,
(select tablespace_name , sum(blocks)*8/(1024)  exp_space from
dba_undo_extents where status NOT IN ('ACTIVE','UNEXPIRED')  group by  tablespace_name) u
WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+)
AND d.tablespace_name=u.tablespace_name  AND d.contents = 'UNDO' AND u.tablespace_name in (select UPPER(value)
from sys.gv\$parameter where name = 'undo_tablespace');
spool off;

SET MARKUP HTML ON SPOOL ON -
 HEAD '<br><br><br><br><h3><left>Invalid Objects</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_7.out
SELECT COUNT(*) as Invalid_objects FROM DBA_OBJECTS WHERE STATUS='INVALID';
spool off;

SET MARKUP HTML OFF;

cat /home/oracle/HC/"$ORACLE_SID"_Health_DB_Status_$date.log >> $LOGFILE
echo "Database Current Details"
$ORACLE_HOME/bin/sqlplus -s /nolog <<ENDINP > /home/oracle/HC/"$ORACLE_SID"_Health_DB_curr_status.out
connect / as sysdba
show user;
set lines 300 pages 300
set heading on

SET MARKUP HTML ON SPOOL ON -
HEAD '<br><br><br><br><h3><left>RMAN Backup status</left></h3>-
 <style type="text/css"> -
    table { background: #eee; } -
    th { font:bold 10pt Arial,Helvetica,sans-serif; color:#b7ceec; background:#151b54; padding: 5px; align:center; } -
    td { font:10pt Arial,Helvetica,sans-serif; color:blue; background:#f7f7e7; padding: 5px; align:center; } -
 </style>' TABLE "border='1' align='left'" ENTMAP OFF

spool /home/oracle/HC/Health_HTML_8.out
SELECT TO_CHAR(start_time, 'DD-MM-YYYY HH24:MI:SS') Starttime,
TO_CHAR(end_time, 'DD-MM-YYYY HH24:MI:SS') Endtime,
output_device_type,
status,
input_type,
round(compression_ratio,2) compression,
INPUT_BYTES_DISPLAY inputbytes,
output_bytes_display outputbytes,input_bytes_per_sec_display inputps,output_bytes_per_sec_display outputps,
time_taken_display
FROM v\$RMAN_BACKUP_JOB_DETAILS WHERE START_TIME > SYSDATE -2 AND INPUT_TYPE LIKE 'DB%'
ORDER BY START_TIME DESC;
spool off;

SET MARKUP HTML OFF;
exit;
ENDINP
cat /home/oracle/HC/Health_DB_info.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_1.out > /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_2.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_3.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_4.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_5.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_6.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_7.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_8.out >> /home/oracle/HC/Health_HTML_out.html
cat /home/oracle/HC/Health_HTML_out.html >> $LOGFILE
echo "" >> $LOGFILE
echo "<br>" >> $LOGFILE
echo "<br>" >> $LOGFILE
echo "<br>" >> $LOGFILE
echo "<br>" >> $LOGFILE
echo "" >> $LOGFILE
mv_src_dir=/home/oracle/HC
mv_dest_dir=/home/oracle/HC/moved_logs
move_list_logfile=/home/oracle/HC/Health_move_list_files.log
echo "Moving 1 day before logfiles"
find . -name "*Health*" -mtime +1 -exec ls -ltr {} \; > $move_list_logfile
echo "Moving 1 day before logfiles"
find $mv_src_dir -name "*Health*" -mtime +1 -type f -exec mv "{}" $mv_dest_dir \;
echo "Moved 1 day before logfiles"
rm_ls_log=/home/oracle/HC/Health_rm_ls_files.log
cd $mv_dest_dir
echo "Listing 90 days old logs files before delete"
find . -name "*Health*" -mtime +90 -exec ls -ltr {} \; > $rm_ls_log
echo "Removing 90 days old logs files"
#find . -name "*Health*" -mtime +90 -exec rm {} \;
echo "Removed 90 days old logs files"
echo "Health Check Script Completed."
echo "Mailing"
MAIL_DB_LOGFILE=/home/oracle/HC/"$ORACLE_SID"_DB_Health_check_status_$date.html
MAIL=DB_HTML
#uuencode $MAIL_DB_LOGFILE PROD_DB_Health_check_status_$date.html > $MAIL
mailx -a $MAIL_DB_LOGFILE -s "Health Check Status:MOG PROD Oracle Database" vikas.b@4iapps.com < /dev/null
exit 0
