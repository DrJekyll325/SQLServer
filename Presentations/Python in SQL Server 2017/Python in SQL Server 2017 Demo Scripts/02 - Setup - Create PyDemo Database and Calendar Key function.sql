USE master;
GO

--	Create PyDemo database and objects
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'PyDemo')
BEGIN

	CREATE DATABASE PyDemo ON PRIMARY
	(
		NAME = N'PyDemo',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\PyDemo.mdf',
		SIZE = 2048000KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 256000KB
	)
	LOG ON
	(
		NAME = N'PyDemo_log',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\PyDemo_log.ldf',
		SIZE = 2048000KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 2048000KB
	);

END;
GO


USE PyDemo;
GO


CREATE SCHEMA dim;
GO
CREATE SCHEMA fact;
GO
CREATE SCHEMA report;
GO


--	Create calendar date key function
IF EXISTS(SELECT * FROM sys.objects WHERE name = 'ufnCalendarDateKey')
	DROP FUNCTION dbo.ufnCalendarDateKey;
GO

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
