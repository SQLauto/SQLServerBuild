/*

EVENT NOTIFICATION 

	Configures event notification on the Admin databases 
		Logs data to the [Admin].dbo.NotificationLog Table
		Creates Agent job (DBA_Event Maintenance) 
			and schedule (run every day at 3:00) to delete data older than 30 days from table

	Script can be run multiple times as it drops and re-creates all event notification objects 


*/

-- Enable Service Broker if it isn't already 
IF EXISTS ( SELECT  *
            FROM    sys.databases
            WHERE   name = 'Admin'
                    AND is_broker_enabled = 0 )
    ALTER DATABASE Admin SET ENABLE_BROKER;
PRINT 'Enabling Service Broker on Database Admin'
GO

-- Run the rest of the script in Admin 
USE [Admin]
GO

-- Create table for Event Notification Results in Admin 
IF NOT EXISTS ( SELECT  [name]
                FROM    sys.tables
                WHERE   [name] = 'NotificationLog' )
CREATE TABLE NotificationLog
    (
      LoggingID INT IDENTITY(1, 1)
                    PRIMARY KEY CLUSTERED ,
      SQLInstance VARCHAR(100) ,
      DatabaseName VARCHAR(100) ,
      EventTime DATETIME ,
      EventType VARCHAR(100) ,
      LoginName VARCHAR(100) ,
      DatabaseUser VARCHAR(100) ,
      ClientHostName VARCHAR(100) ,
      NTUserName VARCHAR(100) ,
      NTDomainName VARCHAR(100) ,
      SchemaName VARCHAR(100) ,
      ObjectName VARCHAR(100) ,
      ObjectType VARCHAR(100) ,
      Success INT ,
      FullSQL VARCHAR(MAX) ,
      FullLog XML ,
      Archived BIT NOT NULL
	  CONSTRAINT DF_NotificationLog_Archived DEFAULT 0 
    )
GO

-- CREATE INDICES
IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_NotificationLog_EventTime' AND object_id = OBJECT_ID('dbo.NotificationLog'))
    DROP INDEX IX_NotificationLog_EventTime ON [dbo].[NotificationLog];
GO
CREATE NONCLUSTERED INDEX [IX_NotificationLog_EventTime] 
ON [dbo].[NotificationLog]
(
		[EventTime] ASC
)
GO


IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_NotificationLog_EventType' AND object_id = OBJECT_ID('dbo.NotificationLog'))
    DROP INDEX IX_NotificationLog_EventType ON [dbo].[NotificationLog];
GO
CREATE NONCLUSTERED INDEX [IX_NotificationLog_EventType]
ON [dbo].[NotificationLog]
(
    [EventType],
    EventTime
);
GO

-- CREATE VIEWS
IF OBJECT_ID('dbo.vNotificationLogDeadlock', 'V') IS NOT NULL
    DROP VIEW dbo.vNotificationLogDeadlock
GO
CREATE VIEW dbo.vNotificationLogDeadlock
AS
SELECT *
FROM [Admin].[dbo].[NotificationLog]
WHERE EventType = 'DEADLOCK_GRAPH';
GO

IF OBJECT_ID('dbo.vNotificationLogDDL', 'V') IS NOT NULL
    DROP VIEW dbo.vNotificationLogDDL
GO
CREATE VIEW [dbo].[vNotificationLogDDL]
AS
SELECT *
FROM [Admin].[dbo].[NotificationLog]
WHERE EventType IN ( 'ALTER_SERVER_CONFIGURATION', 'ALTER_ASSEMBLY', 'CREATE_ASSEMBLY', 'DROP_ASSEMBLY',
                     'ALTER_APPLICATION_ROLE', 'CREATE_APPLICATION_ROLE', 'DROP_APPLICATION_ROLE',
                     'ALTER_ASYMMETRIC_KEY', 'CREATE_ASYMMETRIC_KEY', 'DROP_ASYMMETRIC_KEY',
                     'ALTER_AUTHORIZATION_DATABASE', 'ADD_SIGNATURE', 'ADD_SIGNATURE_SCHEMA_OBJECT', 'DROP_SIGNATURE',
                     'DROP_SIGNATURE_SCHEMA_OBJECT', 'ALTER_DATABASE_AUDIT_SPECIFICATION',
                     'CREATE_DATABASE_AUDIT_SPECIFICATION', 'DROP_DATABASE_AUDIT_SPECIFICATION',
                     'ALTER_DATABASE_ENCRYPTION_KEY', 'CREATE_DATABASE_ENCRYPTION_KEY', 'DROP_DATABASE_ENCRYPTION_KEY',
                     'DENY_DATABASE', 'ALTER_MASTER_KEY', 'CREATE_MASTER_KEY', 'DROP_MASTER_KEY', 'ALTER_SCHEMA',
                     'CREATE_SCHEMA', 'DROP_SCHEMA', 'ALTER_SYMMETRIC_KEY', 'CREATE_SYMMETRIC_KEY',
                     'DROP_SYMMETRIC_KEY', 'BIND_DEFAULT', 'CREATE_DEFAULT', 'DROP_DEFAULT', 'UNBIND_DEFAULT',
                     'CREATE_EVENT_NOTIFICATION', 'DROP_EVENT_NOTIFICATION', 'ALTER_EXTENDED_PROPERTY',
                     'CREATE_EXTENDED_PROPERTY', 'DROP_EXTENDED_PROPERTY', 'ALTER_FULLTEXT_CATALOG',
                     'CREATE_FULLTEXT_CATALOG', 'DROP_FULLTEXT_CATALOG', 'ALTER_FULLTEXT_STOPLIST',
                     'CREATE_FULLTEXT_STOPLIST', 'DROP_FULLTEXT_STOPLIST', 'ALTER_FUNCTION', 'CREATE_FUNCTION',
                     'DROP_FUNCTION', 'ALTER_PARTITION_FUNCTION', 'CREATE_PARTITION_FUNCTION',
                     'DROP_PARTITION_FUNCTION', 'ALTER_PARTITION_SCHEME', 'CREATE_PARTITION_SCHEME',
                     'DROP_PARTITION_SCHEME', 'ALTER_PLAN_GUIDE', 'CREATE_PLAN_GUIDE', 'DROP_PLAN_GUIDE',
                     'ALTER_PROCEDURE', 'CREATE_PROCEDURE', 'DROP_PROCEDURE', 'BIND_RULE', 'CREATE_RULE', 'DROP_RULE',
                     'UNBIND_RULE', 'ALTER_SEARCH_PROPERTY_LIST', 'CREATE_SEARCH_PROPERTY_LIST',
                     'DROP_SEARCH_PROPERTY_LIST', 'ALTER_SEQUENCE', 'CREATE_SEQUENCE', 'DROP_SEQUENCE',
                     'ALTER_BROKER_PRIORITY', 'CREATE_BROKER_PRIORITY', 'DROP_BROKER_PRIORITY', 'CREATE_CONTRACT',
                     'DROP_CONTRACT', 'ALTER_MESSAGE_TYPE', 'CREATE_MESSAGE_TYPE', 'DROP_MESSAGE_TYPE', 'ALTER_QUEUE',
                     'CREATE_QUEUE', 'DROP_QUEUE', 'ALTER_REMOTE_SERVICE_BINDING', 'CREATE_REMOTE_SERVICE_BINDING',
                     'DROP_REMOTE_SERVICE_BINDING', 'ALTER_ROUTE', 'CREATE_ROUTE', 'DROP_ROUTE', 'ALTER_SERVICE',
                     'CREATE_SERVICE', 'DROP_SERVICE', 'CREATE_SYNONYM', 'DROP_SYNONYM', 'CREATE_INDEX', 'DROP_INDEX',
                     'ALTER_TABLE', 'CREATE_TABLE', 'DROP_TABLE', 'ALTER_VIEW', 'CREATE_VIEW', 'DROP_VIEW',
                     'ALTER_TRIGGER', 'CREATE_TRIGGER', 'DROP_TRIGGER', 'CREATE_TYPE', 'DROP_TYPE',
                     'ALTER_XML_SCHEMA_COLLECTION', 'CREATE_XML_SCHEMA_COLLECTION', 'DROP_XML_SCHEMA_COLLECTION',
                     'RENAME', 'ALTER_INSTANCE', 'ALTER_AVAILABILITY_GROUP', 'CREATE_AVAILABILITY_GROUP',
                     'DROP_AVAILABILITY_GROUP', 'ALTER_DATABASE', 'CREATE_DATABASE', 'DROP_DATABASE', 'ALTER_ENDPOINT',
                     'CREATE_ENDPOINT', 'DROP_ENDPOINT', 'ALTER_EVENT_SESSION', 'CREATE_EVENT_SESSION',
                     'DROP_EVENT_SESSION', 'CREATE_EXTENDED_PROCEDURE', 'DROP_EXTENDED_PROCEDURE',
                     'ALTER_LINKED_SERVER', 'CREATE_LINKED_SERVER', 'CREATE_LINKED_SERVER_LOGIN',
                     'DROP_LINKED_SERVER_LOGIN', 'DROP_LINKED_SERVER', 'ALTER_MESSAGE', 'CREATE_MESSAGE',
                     'DROP_MESSAGE', 'ALTER_REMOTE_SERVER', 'CREATE_REMOTE_SERVER', 'DROP_REMOTE_SERVER',
                     'ALTER_RESOURCE_GOVERNOR_CONFIG', 'ALTER_RESOURCE_POOL', 'CREATE_RESOURCE_POOL',
                     'DROP_RESOURCE_POOL', 'ALTER_WORKLOAD_GROUP', 'CREATE_WORKLOAD_GROUP', 'DROP_WORKLOAD_GROUP'
                   )
      AND FullSQL NOT LIKE '%REORGANIZE%'
      AND FullSQL NOT LIKE '%REBUILD%'
      AND ObjectName <> 'telemetry_xevents';

GO


IF OBJECT_ID('dbo.vNotificationLogDCL', 'V') IS NOT NULL
    DROP VIEW dbo.vNotificationLogDCL
GO
CREATE VIEW dbo.vNotificationLogDCL
AS
SELECT *
FROM [Admin].[dbo].[NotificationLog]
WHERE EventType IN ( 'GRANT_DATABASE', 'REVOKE_DATABASE', 'CREATE_CERTIFICATE', 'ALTER_CERTIFICATE',
                     'DROP_CERTIFICATE', 'CREATE_CREDENTIAL', 'ALTER_CREDENTIAL', 'DROP_CREDENTIAL', 'ADD_ROLE_MEMBER',
                     'ADD_SERVER_ROLE_MEMBER', 'CREATE_USER', 'ALTER_USER', 'DROP_USER', 'DROP_ROLE_MEMBER',
                     'ALTER_ROLE', 'CREATE_ROLE', 'DROP_ROLE', 'DROP_SERVER_ROLE_MEMBER', 'ALTER_SERVER_ROLE',
                     'CREATE_SERVER_ROLE', 'ALTER_AUTHORIZATION_SERVER', 'ALTER_CRYPTOGRAPHIC_PROVIDER',
                     'CREATE_CRYPTOGRAPHIC_PROVIDER', 'DROP_CRYPTOGRAPHIC_PROVIDER', 'DENY_SERVER', 'GRANT_SERVER',
                     'REVOKE_SERVER', 'ALTER_LOGIN', 'CREATE_LOGIN', 'DROP_LOGIN', 'ALTER_SERVER_AUDIT',
                     'CREATE_SERVER_AUDIT', 'DROP_SERVER_AUDIT', 'ALTER_SERVER_AUDIT_SPECIFICATION',
                     'CREATE_SERVER_AUDIT_SPECIFICATION', 'DROP_SERVER_AUDIT_SPECIFICATION',
                     'ALTER_SERVICE_MASTER_KEY', 'DROP_SERVER_ROLE'
                   );
GO

IF OBJECT_ID('dbo.vNotificationLogAutoGrowth', 'V') IS NOT NULL
    DROP VIEW dbo.vNotificationLogAutoGrowth
GO
CREATE VIEW dbo.vNotificationLogAutoGrowth
AS
SELECT *
FROM [Admin].[dbo].[NotificationLog]
WHERE EventType IN ( 'LOG_FILE_AUTO_GROW', 'DATA_FILE_AUTO_GROW' );
GO



-- Create Stored Procedure to loop looing for Event Notifcations 
IF OBJECT_ID('dbo.auditQueueReceive') IS NULL
  EXEC ('CREATE PROCEDURE dbo.auditQueueReceive AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[auditQueueReceive]
AS
    BEGIN
        SET NOCOUNT ON;
        SET ARITHABORT ON;
        DECLARE @message XML ,
            @messageName NVARCHAR(256) ,
            @dialogue UNIQUEIDENTIFIER;

        BEGIN TRY
            WHILE ( 1 = 1 )
                BEGIN

                    BEGIN TRANSACTION;
                    SET @dialogue = NULL;
                    WAITFOR (
            GET CONVERSATION GROUP @dialogue FROM dbo.auditQueue
                ), TIMEOUT 2000;
                    IF @dialogue IS NULL
                        BEGIN
                            ROLLBACK;
                            BREAK;
                        END;
                    RECEIVE TOP(1)
            @messageName=message_type_name,
            @message=message_body,
            @dialogue = conversation_handle
            FROM dbo.auditQueue
            WHERE conversation_group_id = @dialogue;
      
				-- filter results
				IF  (( @message.value('(/EVENT_INSTANCE/LoginName)[1]', 'VARCHAR(100)') ) NOT IN ( 'NT SERVICE\SQLTELEMETRY' ))
				BEGIN	
					IF 	(( @message.value('(/EVENT_INSTANCE/EventType)[1]','VARCHAR(100)')) NOT LIKE N'ALTER_EVENT_SESSION')
					BEGIN
										INSERT  INTO NotificationLog
												( SQLInstance ,
												  DatabaseName ,
												  EventTime ,
												  EventType ,
												  LoginName ,
												  DatabaseUser ,
												  ClientHostName ,
												  NTUserName ,
												  NTDomainName ,
												  SchemaName ,
												  ObjectName ,
												  ObjectType ,
												  Success ,
												  FullSQL ,
												  FullLog   
												)
										VALUES  ( ISNULL(@message.value('(/EVENT_INSTANCE/SQLInstance)[1]',
																		'VARCHAR(100)'),
														 @@SERVERNAME) ,
												  ISNULL(@message.value('(/EVENT_INSTANCE/DatabaseName)[1]',
																		'VARCHAR(100)'),
														 'SERVER') ,
												  @message.value('(/EVENT_INSTANCE/PostTime)[1]',
																 'DATETIME') ,
												  @message.value('(/EVENT_INSTANCE/EventType)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/LoginName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/UserName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/HostName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/NTUserName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/NTDomainName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/SchemaName)[1]',
																 'VARCHAR(100)') ,
												  @message.value('(/EVENT_INSTANCE/ObjectName)[1]',
																 'VARCHAR(50)') ,
												  @message.value('(/EVENT_INSTANCE/ObjectType)[1]',
																 'VARCHAR(50)') ,
												  @message.value('(/EVENT_INSTANCE/Success)[1]',
																 'INTEGER') ,
												  @message.value('(/EVENT_INSTANCE/TSQLCommand)[1]',
																 'VARCHAR(max)') ,
												  @message
												);
									END
					END
                    COMMIT
                END
        END TRY
        BEGIN CATCH
            DECLARE @errorNumber INT ,
                @errorMessage NVARCHAR(MAX) ,
                @errorState INT ,
                @errorSeverity INT ,
                @errorLine INT ,
                @errorProcedure NVARCHAR(128)
            SET @errorNumber = ERROR_NUMBER();
            SET @errorMessage = ERROR_MESSAGE();
            SET @errorState = ERROR_STATE();
            SET @errorSeverity = ERROR_SEVERITY();
            SET @errorLine = ERROR_LINE();
            SET @errorProcedure = ERROR_PROCEDURE();
            IF NOT ( XACT_STATE() = 0 )
                ROLLBACK;
            RAISERROR('%s:%d %s (%d)',@errorSeverity,@errorState,@errorProcedure,@errorLine,@errorMessage,@errorNumber) WITH log;
        END CATCH
    END
GO


/*

DROP OBJECTS
	Objects need to be dropped in specific order 
		Events
		Route
		Service
		Queue

*/

-- DROP EVENT
IF EXISTS ( SELECT  *
            FROM    sys.server_event_notifications
            WHERE   name = N'Event_Deadlock' )
    BEGIN
        DROP EVENT NOTIFICATION Event_Deadlock ON SERVER
        RAISERROR('DROPPED EVENT Event_Deadlock',0,0,1) WITH NOWAIT;
    END

IF EXISTS ( SELECT  *
            FROM    sys.server_event_notifications
            WHERE   name = N'Event_DDL' )
    BEGIN
        DROP EVENT NOTIFICATION Event_DDL ON SERVER
        RAISERROR('DROPPED EVENT Event_DDL',0,0,1) WITH NOWAIT;
    END

IF EXISTS ( SELECT  *
            FROM    sys.server_event_notifications
            WHERE   name = N'Event_File' )
    BEGIN
        DROP EVENT NOTIFICATION Event_File ON SERVER
        RAISERROR('DROPPED EVENT Event_File',0,0,1) WITH NOWAIT;
    END

-- DROP ROUTE IF EXISTS
IF EXISTS ( SELECT  *
            FROM    sys.routes
            WHERE   name = N'AuditRoute' )
    BEGIN
        DROP ROUTE AuditRoute
        RAISERROR('DROPPED ROUTE AuditRoute',0,0,1) WITH NOWAIT;
    END

-- DROP SERVICE IF EXISTS
IF EXISTS ( SELECT  *
            FROM    sys.services
            WHERE   name = N'AuditService' )
    BEGIN
        DROP SERVICE AuditService
        RAISERROR('DROPPED SERVICE AuditService',0,0,1) WITH NOWAIT;
    END

-- DROP QUEUE IF EXISTS
IF EXISTS ( SELECT  *
            FROM    sys.service_queues
            WHERE   name = N'AuditQueue' )
    BEGIN
        DROP QUEUE AuditQueue
        RAISERROR('DROPPED QUEUE AuditQueue',0,0,1) WITH NOWAIT;
    END

/*

CREATE OBJECTS
	Objects have to be created in specific order
		Queue
		Service
		Route
		Event
*/

-- CREATE QUEUE
CREATE QUEUE AuditQueue
WITH ACTIVATION (
STATUS = ON,
PROCEDURE_NAME = [Admin].dbo.AuditQueueReceive ,
MAX_QUEUE_READERS = 2, EXECUTE AS SELF)
GO

--CREATE SERVICE
CREATE SERVICE AuditService
ON QUEUE [AuditQueue]
([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification])
GO

--CREATE ROUTE
CREATE ROUTE AuditRoute
WITH SERVICE_NAME = 'AuditService',
ADDRESS = 'Local'
GO


--CREATE EVENT
CREATE EVENT NOTIFICATION Event_File
ON SERVER
WITH FAN_IN
FOR TRC_DATABASE 
TO SERVICE 'AuditService', 'current database'
GO

CREATE EVENT NOTIFICATION Event_Deadlock
ON SERVER
WITH FAN_IN
FOR DEADLOCK_GRAPH
TO SERVICE 'AuditService', 'current database'
GO

CREATE EVENT NOTIFICATION Event_DDL
ON SERVER
WITH FAN_IN
FOR DDL_EVENTS
TO SERVICE 'AuditService', 'current database'
GO



-- Agent job for deleting data older than 30 days
