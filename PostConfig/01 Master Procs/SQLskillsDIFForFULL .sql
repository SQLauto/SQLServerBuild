/*

    SQLskillsDIFForFULL

        Allows to gather data on the amount of change in a database (inserts,updates,deletes) in % to analyize its usage
        Creates function msdb.dbo.SQLskillsConvertToExtents

*/

/*============================================================================
   File: SQLskillsDIFForFULL.sql

   Summary: This script creates a system-wide SP SQLskillsDIFForFILL that
   works out what percentage of a database has changed since the
   previous full database backup.

   Date: April 2008

   SQL Server Versions:
         10.0.1300.13 (SS2008 February CTP � CTP-6)
         9.00.3054.00 (SS2005 SP2)
��������������������������
   Copyright (C) 2008 Paul S. Randal, SQLskills.com
   All rights reserved.

   For more scripts and sample code, check out 
      http://www.sqlskills.com/

   You may alter this code for your own *non-commercial* purposes. You may
   republish altered code as long as you give due credit.


   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
   PARTICULAR PURPOSE.

============================================================================*/

-- Create the function in MSDB

USE msdb;
GO


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   NAME = 'SQLskillsConvertToExtents' )
    DROP FUNCTION SQLskillsConvertToExtents;
GO

/*
� This function cracks the output from a DBCC PAGE dump
� of an allocation bitmap. It takes a string in the form
� "(1:8) � (1:16)" or "(1:8) -" and returns the number
� of extents represented by the string. Both the examples
� above equal 1 extent.
*/


CREATE FUNCTION SQLskillsConvertToExtents ( @extents VARCHAR(100) )
RETURNS INTEGER
AS
    BEGIN
        DECLARE @extentTotal INT;
        DECLARE @colon INT;
        DECLARE @firstExtent INT;
        DECLARE @secondExtent INT;


        SET @extentTotal = 0;
        SET @colon = CHARINDEX(':', @extents);

   -- Check for the single extent case
--
        IF ( CHARINDEX(':', @extents, @colon + 1) = 0 )
            SET @extentTotal = 1;
        ELSE
    -- We're in the multi-extent case
    --
            BEGIN
                SET @firstExtent = CONVERT (INT, SUBSTRING(@extents,
                                                           @colon + 1,
                                                           CHARINDEX(')',
                                                              @extents, @colon)
                                                           - @colon - 1));
                SET @colon = CHARINDEX(':', @extents, @colon + 1);
                SET @secondExtent = CONVERT (INT, SUBSTRING(@extents,
                                                            @colon + 1,
                                                            CHARINDEX(')',
                                                              @extents, @colon)
                                                            - @colon - 1));
                SET @extentTotal = ( @secondExtent - @firstExtent ) / 8 + 1;
            END

        RETURN @extentTotal;
    END;
GO


USE master;
GO


IF OBJECT_ID('sp_SQLskillsDIFForFULL') IS NOT NULL
    DROP PROCEDURE sp_SQLskillsDIFForFULL;
GO