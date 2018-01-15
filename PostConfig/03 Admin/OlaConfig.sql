/*

	Create olaConfig 

		Creates a reference table for all Ola Hallegren scripts

*/
USE Admin;
GO

IF EXISTS ( SELECT  1
            FROM    INFORMATION_SCHEMA.TABLES
            WHERE   TABLE_TYPE = 'BASE TABLE'
                    AND TABLE_NAME = 'olaConfig' )
    DROP TABLE dbo.olaConfig;
BEGIN
    CREATE TABLE [dbo].[olaConfig]
        (
          [Option] [VARCHAR](255) NULL ,
          [Value] [VARCHAR](255) NULL
        ); 

    DECLARE @BackupLocation VARCHAR(200);
    IF ( @@SERVERNAME LIKE 'DEV%' )
        SET @BackupLocation = '\\fileshare.office.creatormail.co.uk\NonProdBackups';
    ELSE
        IF ( @@SERVERNAME LIKE 'UAT%' )
            SET @BackupLocation = '\\fileshare.office.creatormail.co.uk\NonProdBackups';
    ELSE
        IF ( @@SERVERNAME LIKE 'PRD%' )
           SET @BackupLocation = '\\fileshare.office.creatormail.co.uk\DBA\SQLBackup';
    ELSE
           SET @BackupLocation = '\\fileshare.office.creatormail.co.uk\DBA\SQLBackup';

    INSERT  INTO dbo.olaConfig
            ( [Option] ,
              Value
            )
    VALUES  ( 'BackupDirectory' , -- Option - varchar(200)
              @BackupLocation  -- Value - varchar(max)
            );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupCleanupTime', -- Option - varchar(200)
              '192'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupVerify', -- Option - varchar(200)
              'Y'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupCompress', -- Option - varchar(200)
              'Y'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupCheckSum', -- Option - varchar(200)
              'Y'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupLogToTable', -- Option - varchar(200)
              'Y'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'BackupHistory', -- Option - varchar(200)
              '90'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'EmailHistory', -- Option - varchar(200)
              '14'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'AgentJobHistory', -- Option - varchar(200)
              '90'  -- Value - varchar(max)
              );
    INSERT  INTO dbo.olaConfig
            ( [Option], Value )
    VALUES  ( 'CommandLogHistory', -- Option - varchar(200)
              '120'  -- Value - varchar(max)
              );
			  
END;
