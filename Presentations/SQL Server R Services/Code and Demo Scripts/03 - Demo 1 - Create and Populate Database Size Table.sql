USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.tables WHERE name = 'tblDatabaseSize')
	DROP TABLE dbo.tblDatabaseSize;


CREATE TABLE
	dbo.tblDatabaseSize
(
	PK_DatabaseSize		INT IDENTITY(1, 1) PRIMARY KEY,
	DatabaseName		VARCHAR(10) NOT NULL,
	MeasuredDate		DATE NOT NULL,
	DatabaseSizeInMB	DECIMAL(12, 2) NOT NULL
);


CREATE TABLE
	#tmpDBSize
(
	Day						INT NOT NULL PRIMARY KEY,
	DB1SizeIncreaseInMB		DECIMAL(12, 2) NOT NULL,
	DB2SizeIncreaseInMB		DECIMAL(12, 2) NOT NULL
);

INSERT INTO
	#tmpDBSize
(
	Day,
	DB1SizeIncreaseInMB,
	DB2SizeIncreaseInMB
)
SELECT
	Day,
	DB1SizeIncreaseInMB,
	DB2SizeIncreaseInMB
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''R'',
			@script				= N''set.seed(32574);
									db1Mean <- 275 * 1024 / 1100;
									db1SD <- db1Mean * 25;
									db2Mean <- 150 * 1024 / 1100;
									db2SD <- db2Mean * 25;
									Results <- data.frame("Day" = 1:1100,
													"DB1SizeIncreaseInMB" = rnorm(1100, mean = db1Mean, sd = db1SD),
													"DB2SizeIncreaseInMB" = rnorm(1100, mean = db2Mean, sd = db2SD));'',
			@input_data_1		= N'''',
			@input_data_1_name	= N''myQuery'',
			@output_data_1_name	= N''Results''
		WITH RESULT SETS
		((
			"Day"					INT NOT NULL,
			"DB1SizeIncreaseInMB"	DECIMAL(12, 2) NOT NULL,
			"DB2SizeIncreaseInMB"	DECIMAL(12, 2) NOT NULL
		));');


INSERT INTO
	dbo.tblDatabaseSize
(
	DatabaseName,
	MeasuredDate,
	DatabaseSizeInMB
)
SELECT
	DatabaseName = 'master',
	MeasuredDate = DATEADD(dd, t.SequenceNumber, DATEADD(dd, -1101, CAST(SYSDATETIME() AS DATE))),
	DatabaseSizeInMB = 6
FROM
	Admin.dbo.Tally t
WHERE
		t.SequenceNumber BETWEEN 1 AND 1100;


INSERT INTO
	dbo.tblDatabaseSize
(
	DatabaseName,
	MeasuredDate,
	DatabaseSizeInMB
)
SELECT
	DatabaseName = 'model',
	MeasuredDate = DATEADD(dd, t.SequenceNumber, DATEADD(dd, -1101, CAST(SYSDATETIME() AS DATE))),
	DatabaseSizeInMB = 3
FROM
	Admin.dbo.Tally t
WHERE
		t.SequenceNumber BETWEEN 1 AND 1100;


INSERT INTO
	dbo.tblDatabaseSize
(
	DatabaseName,
	MeasuredDate,
	DatabaseSizeInMB
)
SELECT
	DatabaseName = 'msdb',
	MeasuredDate = DATEADD(dd, t.SequenceNumber, DATEADD(dd, -1101, CAST(SYSDATETIME() AS DATE))),
	DatabaseSizeInMB = 16
FROM
	Admin.dbo.Tally t
WHERE
		t.SequenceNumber BETWEEN 1 AND 1100;


WITH Dates
(
	DayNumber,
	CalendarDate
)
AS
(
	SELECT
		DayNumber = t.SequenceNumber,
		CalendarDate = DATEADD(dd, t.SequenceNumber, DATEADD(dd, -1101, CAST(SYSDATETIME() AS DATE)))
	FROM
		Admin.dbo.Tally t
	WHERE
		t.SequenceNumber BETWEEN 1 AND 1100
)
INSERT INTO
	dbo.tblDatabaseSize
(
	DatabaseName,
	MeasuredDate,
	DatabaseSizeInMB
)
SELECT
	DatabaseName = 'RDemo',
	MeasuredDate = Dates.CalendarDate,
	DatabaseSizeInMB = (75 * 1024) + SUM(Sz.DB1SizeIncreaseInMB) OVER (ORDER BY Sz.Day)
FROM
	#tmpDBSize Sz
		INNER JOIN
	Dates
		ON Sz.Day = Dates.DayNumber;


WITH Dates
(
	DayNumber,
	CalendarDate
)
AS
(
	SELECT
		DayNumber = t.SequenceNumber,
		CalendarDate = DATEADD(dd, t.SequenceNumber, DATEADD(dd, -1101, CAST(SYSDATETIME() AS DATE)))
	FROM
		Admin.dbo.Tally t
	WHERE
		t.SequenceNumber BETWEEN 1 AND 1100
)
INSERT INTO
	dbo.tblDatabaseSize
(
	DatabaseName,
	MeasuredDate,
	DatabaseSizeInMB
)
SELECT
	DatabaseName = 'RDemo2',
	MeasuredDate = Dates.CalendarDate,
	DatabaseSizeInMB = (25 * 1024) + SUM(Sz.DB2SizeIncreaseInMB) OVER (ORDER BY Sz.Day)
FROM
	#tmpDBSize Sz
		INNER JOIN
	Dates
		ON Sz.Day = Dates.DayNumber;


DROP TABLE #tmpDBSize;


SELECT
	MeasuredDate,
	DatabaseName,
	DatabaseSizeInMB
FROM
	dbo.tblDatabaseSize
ORDER BY
	MeasuredDate,
	DatabaseName;
