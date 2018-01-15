# SQLServerBuild

### Install-SQLServer.ps1

	Installs SQL Server Engine 
	
### Install-SQLServerBI.ps1

	Installs SQL Server Engine / SSIS / SSRS

### PostConfigWrapper.ps1

    This script runs all post deployment steps

        Run all .SQL Scripts in PostConfig folder
        Configure Max Memory to suggested level
        Configure PowerPlan to suggested level
        Configure MaxDop to suggested level
        Configure TempDB to suggested level

### PostConfig
##### 01 Master Procs

	Install community scripts to master:
		sp_blitz
		sp_blitzcache
		sp_blitzfirst 
		sp_blitzIndex
		sp_blitzLock
		sp_DBPermissions
		sp_SrvPermissions
		sp_whoisactive

##### 02 System Config
01ConfigureDBMail.sql

        Enable dbmail 
        Configure Account (SQLServerAlerts@domain.co.uk) 
        Configure Profile (@@servername + ' Database Mail')
        Configure SQL Server Agent (Mail Profile, Replace Tokens for all Jobs)
        Restart SQL Server Agent (IF Win 2003 Manual Restart Needed)
        Return all Profiles and Accounts on Instance at Present

02AddOperator.sql

		Add DBA Operator (DBA@domain.co.uk and set to FailSafeOperator)

AddAlerts.sql

		Create Error 823-825 and Severity 17-25 (Creates Alerts pointing to Operator: DBA)

AuditConfiguration.sql

		Ensure only failed logins are recorded in the errorlog

DBAAgentCategory.sql

		Create the DBA category

ErrorLogConfiguration.sql

        Set Error Logs Number to 99 
        Set Error Log Max File Size (500mb)

MSDBMaintenance.sql

        Removes Agent jobs (MSDB maintenace is delt with by DBA_MSDB History Cleanup)
	        sp_delete_backuphistory
	        sp_dlete_jobhistory
	        syspolicy_purge_history
        
        Adds indexes to MSDB
	Set history and retention to -1 

spConfigure.sql

        Enable 'backup compression default'
        Enable 'optimize for ad hoc workloads'
        Enable 'remote admin connections'

SQLAgentConfiguration.sql

	No Max history of rows set (history is deleted via DBA_MSDB job)

##### 03 Admin
00AdminDatabase.sql

	Creates Admin database 

Event Notification.sql

	Sets up Event notification objects and table
	Sets up events for DDL, growth and deadlocks

EventMaintenance_AgentJob.sql

	Sets up a agent job to delete history

MaintenanceSolution.sql

	Installs Ola Hallengren maintenace scripts

OlaConfig.sql

	Creates a reference table for all Ola Hallegren scripts

##### 04 Security

Default empty, used for setting up environment groups or roles for dbs / servers

##### 99 Agent Jobs

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
		

### PostConfigBI
##### SSIS Folder
SSIS Config.sql

		Alter size 
		Simple Recovery
		Set owner
		Set catalog retention and project versions


##### SSRS Folder
sp_BlitzRS.sql
	
		Old BrentOzar.com SSRS procedure

SSRS Config.sql

		Alter size 
		Set owner
		Simple recovery