 
/*

	Create RunningJobCheck

		Checks the server for Jobs that have been running longer than the specified number of minutes for the @MaxMinutes parameter.
		Author:      Jonathan Kehayias
 
 */
USE master
GO

IF OBJECT_ID('dbo.RunningJobCheck') IS NOT NULL
    DROP PROC dbo.RunningJobCheck;
GO

CREATE PROCEDURE [dbo].[RunningJobCheck] (@RunLocal bit = 0, @MaxMinutes int = 70)
AS 
BEGIN 
 
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '#RunningJobs%') 
	DROP TABLE #RunningJobs 
CREATE TABLE #RunningJobs
( 
	rowid int IDENTITY PRIMARY KEY,
	spid smallint NOT NULL,
	job_name sysname NOT NULL, 
	program_name nchar(128) NOT NULL, 
	minutesrunning int NOT NULL, 
	starttime datetime NOT NULL
)
 
INSERT INTO #RunningJobs (spid, job_name, program_name, minutesrunning, starttime)
SELECT p.spid, j.name, p.program_name, isnull(DATEDIFF(mi, p.last_batch, getdate()), 0) [MinutesRunning], last_batch
FROM master..sysprocesses p
JOIN msdb..sysjobs j ON (substring(left(j.job_id,8),7,2) +
		substring(left(j.job_id,8),5,2) +
		substring(left(j.job_id,8),3,2) +
		substring(left(j.job_id,8),1,2))  = substring(p.program_name,32,8)
WHERE program_name like 'SQLAgent - TSQL JobStep (Job %'
  AND isnull(DATEDIFF(ss, p.last_batch, getdate()), 0) > @MaxMinutes
 
IF @RunLocal = 1
	BEGIN
	  SELECT * FROM #RunningJobs
	END
ELSE
BEGIN
		DECLARE @Loop int
		DECLARE @Subject varchar(100)
		DECLARE @strMsg varchar(4000)
 
		SELECT @Subject = 'SQL Monitor Alert: ' + @@servername
 
		SELECT @Loop = min(RowID)
		FROM #RunningJobs
 
		WHILE @Loop IS NOT NULL
		BEGIN
 
			SELECT 	@strMsg =  convert(char(15),'JobName:') + isnull(job_name, 'Unknown') + char(10) +
					convert(char(15),'') + 'This job has been running on SPID ' + isnull(convert(varchar, spid), 'Unknown') 
						+ ' for ' + isnull(convert(varchar, minutesrunning), 'Unknown') + ' minutes.' + char(10) +
					convert(char(15),'Program_Name:') + isnull(program_name, 'Unknown') + char(10) +
					convert(char(15),'Start Time:') + isnull(convert(varchar, starttime), 'Unknown')
			FROM #RunningJobs
			WHERE RowID = @Loop
 
			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'CSIMORSYS',
				@recipients = 's.bennett@wellcome.ac.uk',
				@body = @strMsg,
				@subject = @Subject ;
 
			SELECT @Loop = min(RowID)
			FROM #RunningJobs
			WHERE RowID > @Loop
 
		END
END
 
DROP TABLE #RunningJobs
 
END



-- Run Query: exec [dbo].[RunningJobCheck]GO