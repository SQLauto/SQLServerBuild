/*

	SSIS Config

		Alter size 
		Simple Recovery
		Set owner
		Set catalog retention and project versions

*/

USE [master]
GO
ALTER DATABASE [SSISDB] MODIFY FILE ( NAME = N'data', SIZE = 524288KB , FILEGROWTH = 262144KB )
GO
ALTER DATABASE [SSISDB] MODIFY FILE ( NAME = N'log', SIZE = 262144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
GO
ALTER DATABASE [SSISDB] SET RECOVERY SIMPLE WITH NO_WAIT
GO


USE [SSISDB]
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO
EXEC [SSISDB].[catalog].[configure_catalog] @property_name=N'RETENTION_WINDOW', @property_value=60
GO
EXEC [SSISDB].[catalog].[configure_catalog] @property_name=N'MAX_PROJECT_VERSIONS', @property_value=1
GO