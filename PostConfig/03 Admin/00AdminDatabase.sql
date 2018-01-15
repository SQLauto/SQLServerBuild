/*

        Create Admin database 

                Default database for DBA tasks and table for Ola Hallegen maintenance configuraiton
                
                Create database (Admin)
                Create Table (Admin.dbo.olaConfig)


*/

IF NOT EXISTS ( SELECT  *
                FROM    sys.databases
                WHERE   name = 'Admin' )
    CREATE DATABASE Admin;
GO
-- Set DBA to SIMPLE recovery mode
USE [master];
GO
ALTER DATABASE [Admin] SET RECOVERY SIMPLE WITH NO_WAIT;
GO


USE Admin;
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false;
GO
