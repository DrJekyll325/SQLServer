USE master;
GO

--	Create Admin database and objects
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'Admin')
BEGIN

	CREATE DATABASE Admin ON PRIMARY
	(
		NAME = N'Admin',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Admin.mdf',
		SIZE = 20480KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 2560KB
	)
	LOG ON
	(
		NAME = N'Admin_log',
		FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Admin_log.ldf',
		SIZE = 20480KB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 20480KB
	);

END;
GO


USE Admin;
GO


--	Create tally table
IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'Tally')
BEGIN

	CREATE TABLE
		Admin.dbo.Tally
	(
		SequenceNumber		SMALLINT NOT NULL PRIMARY KEY
	);


	INSERT INTO
		Admin.dbo.Tally
	(
		SequenceNumber
	)
	SELECT TOP 10000
		ROW_NUMBER() OVER (ORDER BY col1.name)
	FROM
		sys.syscolumns col1
			CROSS JOIN
		sys.syscolumns col2;

END;
