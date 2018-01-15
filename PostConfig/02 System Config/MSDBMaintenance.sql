/*

    MSDB Maintenace 

        Removes Agent jobs (MSDB maintenace is delt with by DBA_MSDB History Cleanup)
	        sp_delete_backuphistory
	        sp_dlete_jobhistory
	        syspolicy_purge_history
        
        Adds indexes to MSDB
	Set history and retention to -1 
*/




/*

Remove Agent Jobs 

*/
USE [msdb]
GO

IF EXISTS ( SELECT  [name]
            FROM    msdb.dbo.sysjobs
            WHERE   name = 'sp_delete_backuphistory' )
    BEGIN

        EXEC sp_delete_job @job_name = N'sp_delete_backuphistory';

    END


IF EXISTS ( SELECT  [name]
            FROM    msdb.dbo.sysjobs
            WHERE   name = 'sp_purge_jobhistory' )
    BEGIN

        EXEC sp_delete_job @job_name = N'sp_purge_jobhistory';

    END


IF EXISTS ( SELECT  [name]
            FROM    msdb.dbo.sysjobs
            WHERE   name = 'syspolicy_purge_history' )
    BEGIN

        EXEC sp_delete_job @job_name = N'syspolicy_purge_history';

    END

	


/*

Adds indexes to MSDB
http://sirsql.net/blog/2011/1/25/keeping-msdb-clean.html

*/

USE [msdb]
GO
IF NOT EXISTS ( SELECT  *
                FROM    sys.indexes
                WHERE   OBJECT_ID = OBJECT_ID('[dbo].[backupset]')
                        AND name = 'IDX_BackupSet_FinDate_MediaSet' )
    CREATE NONCLUSTERED INDEX IDX_BackupSet_FinDate_MediaSet ON backupset(backup_finish_date) INCLUDE (media_set_id)
 
IF NOT EXISTS ( SELECT  *
                FROM    sys.indexes
                WHERE   OBJECT_ID = OBJECT_ID('[dbo].[backupset]')
                        AND name = 'IDX_BackupSet_MediaSet' )
    CREATE NONCLUSTERED INDEX IDX_BackupSet_MediaSet ON backupset(media_set_id)



/*

Set history and retention to -1 (infinte) use DBA Maintenance job to clear

*/

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=-1, 
		@jobhistory_max_rows_per_job=-1
GO
