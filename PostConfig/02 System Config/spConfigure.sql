/*

    Configures SQL Server instances

        Enable 'backup compression default'
        Enable 'optimize for ad hoc workloads'
        Enable 'remote admin connections'
		Enable 'clr enabled'

*/

-- Show Advanced Options
EXEC sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO


-- Turn on features based on Edition 
DECLARE @v INT
SET @v = CONVERT(INT, LEFT(CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion')),
                           CONVERT(INT, CHARINDEX('.',
                                                  CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion'))))
                           - 1))

 IF ( @v >= 10 )
    BEGIN
		-- Turn on features 2008 +
       -- EXEC sp_configure 'xp_cmdshell', 1; 
        EXEC sp_configure 'backup compression default', 1;
        EXEC sp_configure 'optimize for ad hoc workloads', 1;
        EXEC sp_configure 'remote admin connections', 1;
		--EXEC sp_configure 'clr enabled', 1;   
        RECONFIGURE WITH OVERRIDE
    END
 ELSE
    BEGIN
		-- Turn on features 2005
       -- EXEC sp_configure 'xp_cmdshell', 1;  
        EXEC sp_configure 'remote admin connections', 1;
        RECONFIGURE WITH OVERRIDE
    END;
GO
-- Turn off Advanced options
sp_configure 'show advanced options', 0;
GO
RECONFIGURE WITH OVERRIDE
GO