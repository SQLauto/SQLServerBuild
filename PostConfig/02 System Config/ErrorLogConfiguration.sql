/*

    Configure the ErrorLog to retain 99 errorlogs in stead of 7

        Set Error Logs Number to 99 
        Set Error Log Max File Size (500mb)

*/
/* Set Error Logs Number to 99 */
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 99
GO

USE msdb 
GO

EXEC dbo.sp_cycle_agent_errorlog ;
GO



/* Set Max File size for */
DECLARE @v INT
SET @v = CONVERT(INT, LEFT(CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion')),
                           CONVERT(INT, CHARINDEX('.',
                                                  CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion'))))
                           - 1))
		

IF ( @v >= 12 )
    BEGIN
		
        EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
            N'Software\Microsoft\MSSQLServer\MSSQLServer', N'ErrorLogSizeInKb',
            REG_DWORD, 500
    END
