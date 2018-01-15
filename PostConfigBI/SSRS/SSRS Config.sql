/*

	SSRS Config

		Alter size 
		Set owner
		Simple recovery

*/

-- REPORTSERVER
USE [master]
GO
ALTER DATABASE [ReportServer] MODIFY FILE ( NAME = N'ReportServer', SIZE = 524288KB , FILEGROWTH = 262144KB )
GO
ALTER DATABASE [ReportServer] MODIFY FILE ( NAME = N'ReportServer_log', SIZE = 262144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
GO
ALTER DATABASE [ReportServer] SET RECOVERY SIMPLE WITH NO_WAIT
GO
USE [ReportServer]
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO

-- REPORTSERVERTEMPDB
USE [master]
GO
ALTER DATABASE [ReportServerTempDB] MODIFY FILE ( NAME = N'ReportServerTempDB', SIZE = 524288KB , FILEGROWTH = 262144KB )
GO
ALTER DATABASE [ReportServerTempDB] MODIFY FILE ( NAME = N'ReportServerTempDB_log', SIZE = 262144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
GO
ALTER DATABASE [ReportServerTempDB] SET RECOVERY SIMPLE WITH NO_WAIT
GO
USE [ReportServerTempDB]
GO
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO