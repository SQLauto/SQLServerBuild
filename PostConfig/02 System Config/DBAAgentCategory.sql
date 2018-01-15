/*

	Category Creation
		Create the DBA category


*/
USE msdb ;  
GO  
EXEC dbo.sp_add_category  
    @class=N'JOB',  
    @type=N'LOCAL',  
    @name=N'DBA' ;  
GO  