USE [msdb]
GO

/****** Object:  Job [DBA_EventMaintenance]    Script Date: 26/10/2017 09:03:54 ******/

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA]    Script Date: 26/10/2017 09:03:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF NOT EXISTS(SELECT name FROM msdb.dbo.sysjobs WHERE name = N'DBA_EventMaintenance')
BEGIN
		BEGIN TRANSACTION

		DECLARE @jobId BINARY(16)
		
		EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_EventMaintenance', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=2, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N'This job is to clean up records older than 30 days in the admin database notification log table', 
				@category_name=N'DBA', 
				@owner_login_name=N'sa', 
				@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		/****** Object:  Step [remove older records]    Script Date: 26/10/2017 09:03:54 ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'remove older records', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=N'USE ADMIN
		GO

		DECLARE @RollingDate DATETIME = DATEADD(DAY,-30,GETDATE())

		IF EXISTS(SELECT name FROM sys.tables WHERE name = N''notificationlog'')
		BEGIN
				DELETE FROM dbo.NotificationLog
				WHERE eventtime <= @RollingDate
		END', 
				@database_name=N'master', 
				@flags=4
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
				@enabled=1, 
				@freq_type=4, 
				@freq_interval=1, 
				@freq_subday_type=1, 
				@freq_subday_interval=0, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=0, 
				@active_start_date=20171025, 
				@active_end_date=99991231, 
				@active_start_time=100, 
				@active_end_time=235959
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		COMMIT TRANSACTION
		GOTO EndSave
		QuitWithRollback:
			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		EndSave:
END



