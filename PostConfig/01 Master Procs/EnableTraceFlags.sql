/* 

    Create Stored Procedure to Enable Trace Flags

        Runs at start to enable trace Flags

        Creates stored procedure (master.dbo.EnableTraceFlags)
        Enables 1117, 1118, 3226 by default

        Trace Flag Details:
        all the files in a filegroup to autogrow together http://blogs.technet.com/technet_blog_images/b/sql_server_sizing_ha_and_performance_hints/archive/2012/02/09/sql-server-2008-trace-flag-t-1117.aspx
        Use extents instead of pages in TempDB (http://www.sqlskills.com/blogs/paul/post/misconceptions-around-tf-1118.aspx)
        Prevents successful backup operations from being logeed to events log 
        
*/ 

-- SP to run Trace Flags at startup 
USE master 
GO 
IF OBJECT_ID('dbo.EnableTraceFlags') IS NOT NULL
    DROP PROC dbo.EnableTraceFlags;
GO

CREATE PROC dbo.EnableTraceFlags 
AS 

/* 

-- LIVE ENVIRONMENT 

*/ 
DBCC TRACEON (1117, -1) -- all the files in a filegroup to autogrow together http://blogs.technet.com/technet_blog_images/b/sql_server_sizing_ha_and_performance_hints/archive/2012/02/09/sql-server-2008-trace-flag-t-1117.aspx
DBCC TRACEON (1118, -1) -- Use extents instead of pages in TempDB (http://www.sqlskills.com/blogs/paul/post/misconceptions-around-tf-1118.aspx)
-- DBCC TRACEON (610, -1) -- Minimise logged inserts into index 
-- DBCC TRACEON (2528, -1) -- Disables parrallelism during executing of dbcc statements 
DBCC TRACEON (3226, -1) -- Prevents successful backup operations from being logeed to events log 
-- DBCC TRACEON (1204, -1) -- Writes deadlock data to TEXT format in errorlog 
-- DBCC TRACEON (1222, -1) -- Writes deadlock data to XML format in errorlog 
-- DBCC TRACEON (4199, -1) -- Enable Query Optimiser Fixes http://support.microsoft.com/kb/974006) 
-- DBCC TRACEON (4013, -1) -- Audit all logins to the Error Log 

/* 

-- DEV ENVIRONMENT 

*/ 

-- DBCC TRACEON (3604, -1) -- Print the output in query window of DBCC commands 
-- DBCC TRACEON (3605, -1) -- Sends the same output to Errorlog 
-- DBCC TRACEON (1200, -1) -- Returns locking information in real time. 
-- DBCC TRACEON (2520, -1) -- Enable DBCC HELP to return syntax for undocumenteed DBCC 

 

/* 

-- TROUBLESHOOTING 

*/ 

-- DBCC TRACEON (806, -1) -- Enables DBCC Audit on pages to test consistency 
-- DBCC TRACEON (818, -1) -- Enables 2048 ring buffer in memory looking at I/O issues 
-- DBCC TRACEON (3004, -1) -- Returns info on Instant file initialization  
-- DBCC TRACEON (3014, -1) -- Returns nmore info in the Errorlog about Backups 
-- DBCC TRACEON (3422, -1) -- Log record auditing to help with file corruption 
-- DBCC TRACEON (3502, -1) -- Writes info about CHECKPOINTS to the Errorlog 
-- DBCC TRACEON (3505, -1) -- Disables automatic CHECKPOINTS 
GO 


-- Run to enable TF without Restart
EXEC [dbo].[EnableTraceFlags]  


-- Enable the SP to autostart 
EXEC sp_procoption  
    @ProcName = 'EnableTraceFlags' , 
    @OptionName = 'startup' , 
    @OptionValue = 'on';  
GO 

 

/* 

-- DISABLE 
EXEC sp_procoption  
    @ProcName = 'EnableTraceFlags' ,  
    @OptionName = 'startup' , 
    @OptionValue = 'off';  
GO 

*/ 

 
