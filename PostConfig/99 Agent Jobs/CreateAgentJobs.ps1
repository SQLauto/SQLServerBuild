<#  
    Create Agent Jobs for DBA Maintenance Jobs 

        Creates the following jobs 
            DBA_CommandLog Cleanup
            DBA_Cycle ErrorLogs
            DBA_DBBackup - SYSTEM_DATABASES - FULL
            DBA_DBBackup - USER_DATABASES - FULL
            DBA_DBBackup - USER_DATABASES - DIFF
            DBA_DBBackup - USER_DATABASES - LOG
            DBA_DBIntegrityCheck - SYSTEM_DATABASES
            DBA_DBIntegrityCheck - USER_DATABASES
            DBA_IndexOptimize - USER_DATABASES
            DBA_StatisticsOptimize - USER_DATABASES
            DBA_MSDB Maintenance

#>


    param
    (
        [string]$ServerName
    )

#### Import DBATools Module
##if (-not (Get-Module -Name "DBATools")) {
##    # module is not loaded
##    Write-Warning "DBATools is not loaded, loading now"
##    Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://dbatools.io/in)
##}
##else
##{
##    update-dbatools -force
##}
##
##Import-Module DBATools
##
##
#### credentials
##$secpasswd = ConvertTo-SecureString $ChefSAPassword -AsPlainText -Force    #$ChefSAPassword -AsPlainText -Force
##$SACred = New-Object System.Management.Automation.PSCredential ('sa',$secpasswd)
##
## varaibles



<# DBA_CommandLog Cleanup  #>
$CommandLog = @'
DECLARE @CommandLogHistory INT
SET @CommandLogHistory = ( SELECT   [Value]
                           FROM     [Admin].[dbo].[olaConfig]
                           WHERE    [Option] = 'CommandLogHistory'
                         )
DELETE  FROM [Admin].[dbo].[CommandLog]
WHERE   DATEDIFF(dd, StartTime, GETDATE()) > @CommandLogHistory
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_CommandLog Cleanup' -Description 'Clears Ola Commandlog table in Admin database' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_CommandLog Cleanup' -StepName 'Clear Command Log' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_CommandLog Cleanup'  -Schedule MNT-DBA_CommandLogCleanup -StartTime 060000 -FrequencyType Daily -FrequencyInterval EveryDay -Force 

<# DBA_Cycle ErrorLogs #>
New-DbaAgentJob      -SqlInstance $ServerName -Job 'DBA_Cycle ErrorLogs'  -Description 'Cycles Error Log ever night' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_Cycle ErrorLogs'  -StepName 'Cycle ErrorLog'       -Command 'EXEC sp_cycle_errorlog;' -Database msdb -StepId 1 -OnSuccessAction GoToNextStep 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_Cycle ErrorLogs'  -StepName 'Cycle Agent ErrorLog' -Command 'EXEC sp_cycle_agent_errorlog;' -Database msdb  -StepId 2 
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_Cycle ErrorLogs'  -Schedule MNT-DBA_CycleErrorLogs -StartTime 115500 -FrequencyType Daily -FrequencyInterval EveryDay -Force 

<# DBA_DBBackup - SYSTEM_DATABASES - FULL #>
$CommandLog = @'
DECLARE @dir VARCHAR(200) 
DECLARE @clean INT 
DECLARE @verify VARCHAR(1)
DECLARE @compress VARCHAR(1) 
DECLARE @checksum VARCHAR(1) 
DECLARE @log VARCHAR(1) 

SET @dir = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupDirectory'
           );

SET @clean = ( SELECT   Value
               FROM     Admin.dbo.olaConfig
               WHERE    [Option] = 'BackupCleanupTime'
             );

SET @verify = ( SELECT  Value
                FROM    Admin.dbo.olaConfig
                WHERE   [Option] = 'BackupVerify'
              );

SET @compress = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCompress'
                );

SET @checksum = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCheckSum'
                );

SET @log = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupLogToTable'
           );
 
EXECUTE [Admin].[dbo].[DatabaseBackup] @Databases = 'SYSTEM_DATABASES',
    @Directory = @dir, @BackupType = 'FULL', @Verify = @verify,
    @CleanupTime = @clean, @CheckSum = @checksum, @LogToTable = @log

'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBBackup - SYSTEM_DATABASES - FULL' -Description 'Full Backups of System Databases based on Admin.dbo.OlaConfig Table' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBBackup - SYSTEM_DATABASES - FULL' -StepName 'DatabaseBackup - SYSTEM_DATABASES - FULL' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBBackup - SYSTEM_DATABASES - FULL'  -Schedule DBADatabaseBackupSYSTEMDATABASESFULLSch -StartTime 200000 -FrequencyType Daily -FrequencyInterval EveryDay -Force 

<# DBA_DBBackup - USER_DATABASES - FULL #>
$CommandLog = @'
DECLARE @dir VARCHAR(200) 
DECLARE @clean INT 
DECLARE @verify VARCHAR(1)
DECLARE @compress VARCHAR(1) 
DECLARE @checksum VARCHAR(1) 
DECLARE @log VARCHAR(1) 

SET @dir = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupDirectory'
           );

SET @clean = ( SELECT   Value
               FROM     Admin.dbo.olaConfig
               WHERE    [Option] = 'BackupCleanupTime'
             );

SET @verify = ( SELECT  Value
                FROM    Admin.dbo.olaConfig
                WHERE   [Option] = 'BackupVerify'
              );

SET @compress = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCompress'
                );

SET @checksum = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCheckSum'
                );

SET @log = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupLogToTable'
           );
 
EXECUTE [Admin].[dbo].[DatabaseBackup] @Databases = 'USER_DATABASES',
    @Directory = @dir, @BackupType = 'FULL', @Verify = @verify,
    @CleanupTime = @clean, @CheckSum = @checksum, @LogToTable = @log

'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - FULL' -Description 'Full Backups of User Databases based on Admin.dbo.OlaConfig Table' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - FULL' -StepName 'DatabaseBackup - USER_DATABASES - FULL' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - FULL'  -Schedule MNT-DatabaseBackup-USER_DATABASES-FULL -StartTime 201500 -FrequencyType Weekly -FrequencyInterval "Sunday" -Force 

<# DBA_DBBackup - USER_DATABASES - DIFF #>
$CommandLog = @'
DECLARE @dir VARCHAR(200) 
DECLARE @clean INT 
DECLARE @verify VARCHAR(1)
DECLARE @compress VARCHAR(1) 
DECLARE @checksum VARCHAR(1) 
DECLARE @log VARCHAR(1) 

SET @dir = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupDirectory'
           );

SET @clean = ( SELECT   Value
               FROM     Admin.dbo.olaConfig
               WHERE    [Option] = 'BackupCleanupTime'
             );

SET @verify = ( SELECT  Value
                FROM    Admin.dbo.olaConfig
                WHERE   [Option] = 'BackupVerify'
              );

SET @compress = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCompress'
                );

SET @checksum = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCheckSum'
                );

SET @log = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupLogToTable'
           );
 
EXECUTE [Admin].[dbo].[DatabaseBackup] @Databases = 'USER_DATABASES',
    @Directory = @dir, @BackupType = 'DIFF', @Verify = @verify,
    @CleanupTime = @clean, @CheckSum = @checksum, @LogToTable = @log

'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - DIFF' -Description 'Diff Backups of User Databases based on Admin.dbo.OlaConfig Table' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - DIFF' -StepName 'DatabaseBackup - USER_DATABASES - DIFF' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - DIFF'  -Schedule MNT-DatabaseBackup-USER_DATABASES-DIFF -StartTime 201500 -FrequencyType Weekly -FrequencyInterval "Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" -Force 


<# DBA_DBBackup - USER_DATABASES - LOG #>
$CommandLog = @'
DECLARE @dir VARCHAR(200) 
DECLARE @clean INT 
DECLARE @verify VARCHAR(1)
DECLARE @compress VARCHAR(1) 
DECLARE @checksum VARCHAR(1) 
DECLARE @log VARCHAR(1) 

SET @dir = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupDirectory'
           );

SET @clean = ( SELECT   Value
               FROM     Admin.dbo.olaConfig
               WHERE    [Option] = 'BackupCleanupTime'
             );

SET @verify = ( SELECT  Value
                FROM    Admin.dbo.olaConfig
                WHERE   [Option] = 'BackupVerify'
              );

SET @compress = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCompress'
                );

SET @checksum = ( SELECT    Value
                  FROM      Admin.dbo.olaConfig
                  WHERE     [Option] = 'BackupCheckSum'
                );

SET @log = ( SELECT Value
             FROM   Admin.dbo.olaConfig
             WHERE  [Option] = 'BackupLogToTable'
           );
 
EXECUTE [Admin].[dbo].[DatabaseBackup] @Databases = 'USER_DATABASES',
    @Directory = @dir, @BackupType = 'LOG', @Verify = @verify,
    @CleanupTime = @clean, @CheckSum = @checksum, @LogToTable = @log

'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - LOG' -Description 'Log backups of user Databases based on Admin.dbo.OlaConfig Table' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - LOG' -StepName 'DatabaseBackup - SYSTEM_DATABASES - LOG' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBBackup - USER_DATABASES - LOG'  -Schedule MNT-DatabaseBackup-USER_DATABASES-LOG -FrequencyType Daily -FrequencyInterval EveryDay -FrequencySubdayType Minutes -FrequencySubdayInterval 10 -Force 

<# DBA_DBIntegrityCheck - SYSTEM_DATABASES #>
$CommandLog = @'
EXECUTE [Admin].[dbo].[DatabaseIntegrityCheck] 
@Databases = 'SYSTEM_DATABASES', 
@LogToTable = 'Y'
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - SYSTEM_DATABASES' -Description 'Source: http://ola.hallengren.com' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - SYSTEM_DATABASES' -StepName 'DatabaseIntegrityCheck - SYSTEM_DATABASES' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - SYSTEM_DATABASES'  -Schedule MNT-DatabaseIntegrityCheck-SYSTEM_DATABASES -StartTime 020000 -FrequencyType Daily -FrequencyInterval EveryDay -Force 

<# DBA_DBIntegrityCheck - USER_DATABASES #>
$CommandLog = @'
EXECUTE [Admin].[dbo].[DatabaseIntegrityCheck] 
@Databases = 'USER_DATABASES', 
@LogToTable = 'Y'
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - USER_DATABASES' -Description 'Source: http://ola.hallengren.com' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - USER_DATABASES' -StepName 'DatabaseIntegrityCheck - USER_DATABASES' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_DBIntegrityCheck - USER_DATABASES'  -Schedule MNT-DatabaseIntegrityCheck-SYSTEM_DATABASES -StartTime 021500 -FrequencyType Daily -FrequencyInterval EveryDay -Force 


<# DBA_IndexOptimize - USER_DATABASES #>
$CommandLog = @'
EXECUTE [Admin].[dbo].[IndexOptimize] 
@Databases = 'USER_DATABASES', 
@LogToTable = 'Y'
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_IndexOptimize - USER_DATABASES' -Description 'Source: http://ola.hallengren.com' -Category  'Database Maintenance' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_IndexOptimize - USER_DATABASES' -StepName 'DBA_IndexOptimize - USER_DATABASES' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_IndexOptimize - USER_DATABASES'  -Schedule MNT-DBA_IndexOptimize-USER_DATABASES -StartTime 010000 -FrequencyType Weekly -FrequencyInterval "Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" -Force 


<# DBA_StatisticsOptimize - USER_DATABASES #>
$CommandLog = @'
EXECUTE [Admin].[dbo].[IndexOptimize]
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y'
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_StatisticsOptimize - USER_DATABASES' -Description 'Source: http://ola.hallengren.com' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA' -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_StatisticsOptimize - USER_DATABASES' -StepName 'DBA_StatisticsOptimize - USER_DATABASES' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_StatisticsOptimize - USER_DATABASES'  -Schedule DBA_StatisticsOptimize-USER_DATABASES -StartTime 010000 -FrequencyType Weekly -FrequencyInterval "Sunday" -Force 
 

<# DBA_MSDB Maintenance #>
$CommandLog = @'
USE msdb
GO
DECLARE @BackupHistory INT
DECLARE @EmailHistory INT
DECLARE @AgentJobHistory INT

SET @BackupHistory = ( SELECT   [Value]
                       FROM     Admin.dbo.olaConfig
                       WHERE    [Option] = 'BackupHistory'
                     );
SET @EmailHistory = ( SELECT    [Value]
                      FROM      Admin.dbo.olaConfig
                      WHERE     [Option] = 'EmailHistory'
                    );
SET @AgentJobHistory = ( SELECT [Value]
                         FROM   Admin.dbo.olaConfig
                         WHERE  [Option] = 'AgentJobHistory'
                       );

/* Cleanup old backup history */
DECLARE @backupdate DATETIME 
SET @backupdate = DATEADD(d, - @BackupHistory, GETDATE())
EXEC msdb.dbo.sp_delete_backuphistory @backupdate

/* Cleanup old mail items */
DECLARE @maildate DATETIME  
SET @maildate = DATEADD(d, - @EmailHistory, GETDATE())
EXEC msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @maildate
EXEC msdb.dbo.sysmail_delete_log_sp @logged_before = @maildate

/* Cleanup old Agnet Job history */
DECLARE @CleanupDate DATETIME 
SET @CleanupDate = DATEADD(dd, - @AgentJobHistory, GETDATE()) 
EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate


--Truncate below tables to free up space 
TRUNCATE TABLE sysmail_attachments 
TRUNCATE TABLE sysmail_attachments_transfer
TRUNCATE TABLE sysmaintplan_logdetail
'@

New-DbaAgentJob -SqlInstance $ServerName -Job 'DBA_MSDB Maintenance' -Description 'Source: http://ola.hallengren.com' -Category 'DBA' -OwnerLogin 'SA' -EmailLevel OnFailure -EmailOperator 'DBA'  -Force 
New-DbaAgentJobStep  -SqlInstance $ServerName -Job 'DBA_MSDB Maintenance' -StepName 'DBA_MSDB Maintenance' -Command $CommandLog
New-DbaAgentSchedule -SqlInstance $ServerName -Job 'DBA_MSDB Maintenance'  -Schedule MNT-DBA_MSDBMaintenance -StartTime 235000 -FrequencyType Daily -FrequencyInterval EveryDay -Force 



















