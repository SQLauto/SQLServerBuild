/*

    Configure DBMail - Read Message for confirmation ran successfully

        Enable dbmail 
        Configure Account (SQLServerAlerts@Creatormail.co.uk) 
        Configure Profile (@@servername + ' Database Mail')
        Configure SQL Server Agent (Mail Profile, Replace Tokens for all Jobs)
        Restart SQL Server Agent (IF Win 2003 Manual Restart Needed)
        Return all Profiles and Accounts on Instance at Present

*/
-- Return all Profiles and Accounts on Instance at Present
--exec msdb..sysmail_help_profileaccount_sp


/*
-- Enable dbmail 
*/
-- Turn on Database Mail XPs
EXEC sp_configure 'show advanced', 1; 
RECONFIGURE WITH OVERRIDE
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE WITH OVERRIDE
-- Turn off Advanced options
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE WITH OVERRIDE



/*
-- Configure Account and Profile
*/
DECLARE @profileId INT, @Account varchar(100), @mailserver_name VARCHAR(100)

SET @mailserver_name = '192.168.124.200'

SET @Account = @@servername + ' Database Mail'

-- Add Profile
IF NOT EXISTS(select name from msdb..sysmail_profile WHERE name = @Account) 
EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = @Account,
       @profile_id = @profileId OUTPUT;

	
-- Add Account
IF NOT EXISTS(select name from msdb..sysmail_account WHERE name = @Account) 
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = @Account,
    @email_address = 'SQLServerAlerts@Axelos.com',
    @display_name = @Account,
    @replyto_address = 'DoNotReplyL@Axelos.com',
    @mailserver_name = @mailserver_name;

-- Run sysmail_add_profileaccount_sp only if Added Profile
IF (@profileId IS NOT NULL)
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_id = @profileId,
    @account_name = @Account,
    @sequence_number = 1;

-- Run sysmail_add_principalprofile_sp only if Added Profile
IF (@profileId IS NOT NULL)
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @principal_name = 'public',
    @profile_id = @profileId,
    @is_default = '1';

GO


/*
--Agent job settings
*/
USE [msdb]
GO
DECLARE @Acc varchar(100)
SET @Acc = @@servername + ' Database Mail'
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', @Acc
GO
--Replace tokens for all job responses to alerts
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, 
		@alert_replace_runtime_tokens=1
go

-- Return all Profiles and Accounts on Instance at Present
exec msdb..sysmail_help_profileaccount_sp





