USE master;
GO

--	Create new database
CREATE DATABASE MyHospital ON PRIMARY
(
	NAME = N'MyHospital',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\MyHospital.mdf',
	SIZE = 204800KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 25600KB
)
LOG ON
(
	NAME = N'MyHospital_log',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\MyHospital_log.ldf',
	SIZE = 204800KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 204800KB
);
GO


--	Create dim and fact schemas
USE MyHospital;
GO

CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO

CREATE SCHEMA report;
GO

CREATE SCHEMA sec;
GO




--	Create tally table
CREATE TABLE
	dbo.Tally
(
	SequenceNumber		SMALLINT NOT NULL PRIMARY KEY
);


INSERT INTO
	dbo.Tally
(
	SequenceNumber
)
SELECT TOP 10000
	ROW_NUMBER() OVER (ORDER BY col1.name)
FROM
	sys.syscolumns col1
		CROSS JOIN
	sys.syscolumns col2;

GO



--	Create calendar date key function
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

GO
