USE master;
GO

--	Create RDemo database and objects
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'RDemo')
BEGIN

	CREATE DATABASE RDemo ON PRIMARY
	(
		NAME = N'RDemo',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\RDemo.mdf',
		SIZE = 2048000KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 256000KB
	)
	LOG ON
	(
		NAME = N'RDemo_log',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\RDemo_log.ldf',
		SIZE = 2048000KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 2048000KB
	);

END;
GO


USE RDemo;
GO


CREATE SCHEMA dim;
CREATE SCHEMA fact;
CREATE SCHEMA report;


--	Create calendar date key function
IF EXISTS(SELECT * FROM sys.objects WHERE name = 'ufnCalendarDateKey')
	DROP FUNCTION dbo.ufnCalendarDateKey;


CREATE FUNCTION dbo.ufnCalendarDateKey
(
	@CalendarDate	DATE
)
RETURNS INT
AS
BEGIN

	DECLARE @CalendarDateKey INT;

	SET @CalendarDateKey = 10000 * DATEPART(yyyy, @CalendarDate) + 100 * DATEPART(mm, @CalendarDate) + DATEPART(dd, @CalendarDate);

	RETURN @CalendarDateKey;

END;
