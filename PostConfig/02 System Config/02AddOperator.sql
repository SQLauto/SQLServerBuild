/*

    Add DBA Operator (DBA@domain.co.uk and set to FailSafeOperator)

*/

-- Add SQL Server DBA Operator If it doesnt exist
IF NOT EXISTS ( SELECT  name
                FROM    msdb.dbo.sysoperators
                WHERE   name = 'DBA' )
    EXEC msdb.dbo.sp_add_operator @name = N'DBA', @enabled = 1,
        @pager_days = 0, @email_address = N'DBA@domain.com'
GO

-- Set SQL Server DBA Operator as failSafeOperator - Send to Email
USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator = N'DBA'
GO
USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @notificationmethod = 1
GO
USE [msdb]
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail',
    N'REG_DWORD', 1
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 1
GO

/*
-- Show any other Operators that are not SQL Server DBA
SELECT  name AS 'CHECK IF ALL OPERATORS ON THIS SERVER ARE NEEDED'
FROM    msdb.dbo.sysoperators
*/