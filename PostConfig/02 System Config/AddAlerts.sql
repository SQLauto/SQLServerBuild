/*

    Add Alerts 

        Create Error 823-825 and Severity 17-25 (Creates Alerts pointing to Operator: DBA)

*/

-- DROP ALERT Error 823
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   message_id = 823 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    message_id = 823
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Error 823'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Error 823'
END CATCH
GO

-- DROP ALERT Error 824
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   message_id = 824 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    message_id = 824
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Error 824'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Error 824'
END CATCH
GO

-- DROP ALERT Error 825
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   message_id = 825 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    message_id = 825
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Error 825'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Error 825'
END CATCH
GO


-- DROP ALERT Severity 17
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 17 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 17
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 17'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 17'
END CATCH
GO

-- DROP ALERT Severity 18
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 18 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 18
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 18'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 18'
END CATCH
GO

-- DROP ALERT Severity 19
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 19 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 19
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 19'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 19'
END CATCH
GO

-- DROP ALERT Severity 20
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 20 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 20
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 20'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 20'
END CATCH
GO

-- DROP ALERT Severity 21
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 21 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 21
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 21'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 21'
END CATCH
GO

-- DROP ALERT Severity 22
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 22 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 22
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 22'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 22'
END CATCH
GO

-- DROP ALERT Severity 23
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 23 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 23
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 23'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 23'
END CATCH
GO

-- DROP ALERT Severity 24
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 24 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 24
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 24'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 24'
END CATCH
GO

-- DROP ALERT Severity 25
IF EXISTS ( SELECT  name
            FROM    msdb.dbo.sysalerts
            WHERE   severity = 25 )
    DECLARE @s VARCHAR(50)
SET @s = ( SELECT   name
           FROM     msdb.dbo.sysalerts
           WHERE    severity = 25
         )
BEGIN TRY
    PRINT 'Deleting Alert set up for Severity 25'
    EXEC msdb.dbo.sp_delete_alert @name = @s
END TRY
BEGIN CATCH
    PRINT 'No Alert set up for Severity 25'
END CATCH
GO


PRINT 'Adding Alert Severity 017'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 017', @message_id = 0,
    @severity = 17, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 017',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 018'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 018', @message_id = 0,
    @severity = 18, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 018',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 019'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 019', @message_id = 0,
    @severity = 19, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 019',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 020'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 020', @message_id = 0,
    @severity = 20, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 020',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 021'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 021', @message_id = 0,
    @severity = 21, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 021',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 022'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 022', @message_id = 0,
    @severity = 22, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 022',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 023'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 023', @message_id = 0,
    @severity = 23, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 023',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 024'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 024', @message_id = 0,
    @severity = 24, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 024',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Severity 025'
EXEC msdb.dbo.sp_add_alert @name = N'Severity 025', @message_id = 0,
    @severity = 25, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 025',
    @operator_name = N'DBA', @notification_method = 1
GO

--
PRINT 'Adding Alert Error 823'
EXEC msdb.dbo.sp_add_alert @name = N'Error Number 823', @message_id = 823,
    @severity = 0, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Error Number 823',
    @operator_name = N'DBA', @notification_method = 1;
GO

--
PRINT 'Adding Alert Error 824'
EXEC msdb.dbo.sp_add_alert @name = N'Error Number 824', @message_id = 824,
    @severity = 0, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Error Number 824',
    @operator_name = N'DBA', @notification_method = 1;
GO

--
PRINT 'Adding Alert Error 825'
EXEC msdb.dbo.sp_add_alert @name = N'Error Number 825', @message_id = 825,
    @severity = 0, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Error Number 825',
    @operator_name = N'DBA', @notification_method = 1;
GO


