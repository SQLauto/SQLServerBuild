/*

	Update Agent Job Settings

		No Max history of rows set (history is deleted via DBA_MSDB job)

*/

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=-1, 
		@jobhistory_max_rows_per_job=-1
GO