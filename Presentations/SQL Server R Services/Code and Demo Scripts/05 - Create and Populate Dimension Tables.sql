USE RDemo;
GO


--	Create and populate Calendar dimension
CREATE TABLE
	dim.Calendar
(
	CalendarKey			INT NOT NULL,
	CalendarDate		CHAR(10) NOT NULL,
	YearNum				SMALLINT NOT NULL,
	QuarterNum			SMALLINT NOT NULL,
	QuarterShortName	CHAR(2) NOT NULL,
	QuarterLongName		CHAR(7) NOT NULL,
	MonthNum			SMALLINT NOT NULL,
	MonthShortName		VARCHAR(3) NOT NULL,
	MonthLongName		VARCHAR(10) NOT NULL,
	DayNum				SMALLINT NOT NULL,
	DayOfWeekNum		SMALLINT NOT NULL,
	DayOfWeekName		VARCHAR(10) NOT NULL
);

ALTER TABLE dim.Calendar ADD CONSTRAINT PK_Calendar PRIMARY KEY (CalendarKey);


--	Populate Calendar dimension
INSERT INTO dim.Calendar
(CalendarKey, CalendarDate, YearNum, QuarterNum, QuarterShortName, QuarterLongName, MonthNum, MonthShortName, MonthLongName, DayNum, DayOfWeekNum, DayOfWeekName)
VALUES (-1, 'Unknown', 0, 0, 'Q0', 'Q0 0000', 0, 'N/A', 'N/A', 0, 0, 'N/A')


DECLARE
	@StartDate		DATE,
	@EndDate		DATE;

SET @StartDate = '1900-01-01';
SET @EndDate = '2050-12-31';

WITH Tally(SequenceNumber) AS
(
	SELECT
		ROW_NUMBER() OVER (ORDER BY t1.SequenceNumber)
	FROM
		Admin.dbo.Tally t1
			CROSS JOIN
		Admin.dbo.Tally t2
)
INSERT INTO
	dim.Calendar
(
	CalendarKey,
	CalendarDate,
	YearNum,
	QuarterNum,
	QuarterShortName,
	QuarterLongName,
	MonthNum,
	MonthShortName,
	MonthLongName,
	DayNum,
	DayOfWeekNum,
	DayOfWeekName
)
SELECT
	CalendarKey = CAST(10000 * DATEPART(yyyy,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  )
				+ 100 * DATEPART(mm,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  )
				+ DATEPART(dd, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS INT),
	CalendarDate = CONVERT(CHAR(10), DATEADD(dd, t.SequenceNumber - 1, @StartDate), 120),
	YearNum = CAST(DATEPART(yyyy,   DATEADD(dd, t.SequenceNumber - 1, @StartDate)  ) AS SMALLINT),
	QuarterNum = CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	QuarterShortName = CAST ('Q' + CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)) AS CHAR(2)),
	QuarterLongName = CAST(CAST(DATEPART(yyyy, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR) + ' Q'
					+ CAST(DATENAME(quarter, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)) AS CHAR(7)),
	MonthNum = CAST(MONTH(DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	MonthShortName = CAST(DATENAME(month, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(3)),
	MonthLongName = CAST(DATENAME(month, DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS VARCHAR(10)),
	DayNum = CAST(DAY(DATEADD(dd, t.SequenceNumber - 1, @StartDate)) AS SMALLINT),
	DayOfWeekNum = CAST(DATEPART(dw, (DATEADD(dd, t.SequenceNumber - 1, @StartDate))) AS SMALLINT),
	DayOfWeekName = CAST(DATENAME(dw, (DATEADD(dd, t.SequenceNumber - 1, @StartDate))) AS VARCHAR(10))
FROM
	Tally t
WHERE
	t.SequenceNumber <= DATEDIFF(dd, @StartDate, @EndDate) + 1
ORDER BY
	t.SequenceNumber;




--	Create Department dimension
CREATE TABLE
	dim.Department
(
	DepartmentKey				INT IDENTITY(1, 1),
	Practice					VARCHAR(20) NOT NULL,
	Department					VARCHAR(20) NOT NULL,
	Clinic						VARCHAR(20) NOT NULL,
	DepartmentActiveFlag		CHAR(1) NOT NULL,
	DepartmentSourceSystem		VARCHAR(10) NOT NULL,
	DepartmentSourceKey			INT NOT NULL,
	DepartmentLastUpdatedDate	DATE NOT NULL
);

ALTER TABLE dim.Department ADD CONSTRAINT PK_Department PRIMARY KEY (DepartmentKey);


--	Populate Department dimension
SET IDENTITY_INSERT dim.Department ON;

INSERT INTO dim.Department
(DepartmentKey, Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES (-1, 'Unknown', 'Unknown', 'Unknown', 'Y', 'N/A', -1, CAST(SYSDATETIME() AS DATE));

SET IDENTITY_INSERT dim.Department OFF;

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Family Medicine', 'Hospital', 'Y', 'EMR', 1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Family Medicine', 'East Side', 'Y', 'EMR', 2, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Family Medicine', 'North Side', 'Y', 'EMR', 3, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Family Medicine', 'South Side', 'Y', 'EMR', 4, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Family Medicine', 'West Side', 'Y', 'EMR', 5, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Internal Medicine', 'Hospital', 'Y', 'EMR', 6, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Internal Medicine', 'East Side', 'Y', 'EMR', 7, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Internal Medicine', 'West Side', 'Y', 'EMR', 8, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Pediatrics', 'Hospital', 'Y', 'EMR', 9, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Pediatrics', 'East Side', 'Y', 'EMR', 10, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Pediatrics', 'North Side', 'Y', 'EMR', 11, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Pediatrics', 'West Side', 'Y', 'EMR', 12, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Women''s Health', 'Hospital', 'Y', 'EMR', 13, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Women''s Health', 'East Side', 'Y', 'EMR', 14, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Women''s Health', 'North Side', 'Y', 'EMR', 15, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Women''s Health', 'South Side', 'Y', 'EMR', 16, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Primary Care', 'Women''s Health', 'West Side', 'Y', 'EMR', 17, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Cardiology', 'Hospital', 'Y', 'EMR', 101, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Cardiology', 'North Side', 'Y', 'EMR', 102, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Emergency Medicine', 'Hospital', 'Y', 'EMR', 103, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Ophthalmology', 'Hospital', 'Y', 'EMR', 104, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Orthopedics', 'Hospital', 'Y', 'EMR', 105, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Specialty Care', 'Surgery', 'Hospital', 'Y', 'EMR', 106, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Urgent Care', 'Urgent Care', 'Hospital', 'Y', 'EMR', 201, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Urgent Care', 'Urgent Care', 'East Side', 'Y', 'EMR', 202, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Department
(Practice, Department, Clinic, DepartmentActiveFlag, DepartmentSourceSystem, DepartmentSourceKey, DepartmentLastUpdatedDate)
VALUES ('Urgent Care', 'Urgent Care', 'West Side', 'Y', 'EMR', 203, CAST(SYSDATETIME() AS DATE));




--	Create Patient dimension
CREATE TABLE
	dim.Patient
(
	PatientKey					INT IDENTITY(1, 1),
	PatientName					VARCHAR(20) NOT NULL,
	PatientMRN					VARCHAR(10) NOT NULL,
	PatientBirthDate			DATE NOT NULL,
	PatientGender				CHAR(1) NOT NULL,
	PatientActiveFlag			CHAR(1) NOT NULL,
	PatientSourceSystem			VARCHAR(10) NOT NULL,
	PatientSourceKey			INT NOT NULL,
	PatientLastUpdatedDate		DATE NOT NULL
);

ALTER TABLE dim.Patient ADD CONSTRAINT PK_Patient PRIMARY KEY (PatientKey);


--	Populate Patient dimension
SET IDENTITY_INSERT dim.Patient ON;

INSERT INTO dim.Patient
(PatientKey, PatientName, PatientMRN, PatientBirthDate, PatientGender, PatientActiveFlag, PatientSourceSystem, PatientSourceKey, PatientLastUpdatedDate)
VALUES (-1, 'Unknown', 'Unknown', '1900-01-01', 'X', 'Y', 'N/A', -1, CAST(SYSDATETIME() AS DATE));

SET IDENTITY_INSERT dim.Patient OFF;

INSERT INTO
	dim.Patient
(
	PatientName,
	PatientMRN,
	PatientBirthDate,
	PatientGender,
	PatientActiveFlag,
	PatientSourceSystem,
	PatientSourceKey,
	PatientLastUpdatedDate
)
SELECT
	PatientName = 'Patient' + LTRIM(RTRIM(CAST(t.SequenceNumber AS VARCHAR))) + ', Test',
	PatientMRN = '1' + RIGHT('00000000' + LTRIM(RTRIM(CAST(t.SequenceNumber AS VARCHAR))), 9),
	PatientBirthDate = CAST(DATEADD(dd, ABS(CHECKSUM(NEWID()) % 60000), '1950-01-01') AS DATE),
	PatientGender =	CASE
						WHEN t.SequenceNumber % 100 BETWEEN 0 AND 47 THEN 'F'
						WHEN t.SequenceNumber % 100 BETWEEN 48 AND 95 THEN 'M'
						WHEN t.SequenceNumber % 100 BETWEEN 96 AND 99 THEN 'O'
					END,
	PatientActiveFlag = 'Y',
	PatientSourceSystem = 'EMR',
	PatientSourceKey = t.SequenceNumber,
	PatientLastUpdatedDate = CAST(SYSDATETIME() AS DATE)
FROM
	Admin.dbo.Tally t
ORDER BY
	t.SequenceNumber;




--	Create Procedure Code dimension
CREATE TABLE
	dim.ProcedureCode
(
	ProcedureCodeKey				INT IDENTITY(1, 1),
	ProcedureCodePlusDescription	VARCHAR(110) NOT NULL,
	ProcedureCode					VARCHAR(10) NOT NULL,
	ProcedureCodeDescription		VARCHAR(100) NOT NULL,
	ProcedureCodeCategory			VARCHAR(20) NOT NULL,
	ProcedureCodeActiveFlag			CHAR(1) NOT NULL,
	ProcedureCodeSourceSystem		VARCHAR(10) NOT NULL,
	ProcedureCodeSourceKey			INT NOT NULL,
	ProcedureCodeLastUpdatedDate	DATE NOT NULL
)

ALTER TABLE dim.ProcedureCode ADD CONSTRAINT PK_ProcedureCode PRIMARY KEY (ProcedureCodeKey);


--	Populate Procedure Code dimension
SET IDENTITY_INSERT dim.ProcedureCode ON;

INSERT INTO dim.ProcedureCode
(ProcedureCodeKey, ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES (-1, 'Unknown', 'Unknown', 'Unknown', 'N/A', 'Y', 'N/A', -1, CAST(SYSDATETIME() AS DATE));

SET IDENTITY_INSERT dim.ProcedureCode OFF;

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99201 - Office/outpatient visit new', '99201', 'Office/outpatient visit new', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99202 - Office/outpatient visit new', '99202', 'Office/outpatient visit new', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99203 - Office/outpatient visit new', '99203', 'Office/outpatient visit new', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99204 - Office/outpatient visit new', '99204', 'Office/outpatient visit new', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99205 - Office/outpatient visit new', '99205', 'Office/outpatient visit new', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99211 - Office/outpatient visit est', '99211', 'Office/outpatient visit est', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99212 - Office/outpatient visit est', '99212', 'Office/outpatient visit est', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99213 - Office/outpatient visit est', '99213', 'Office/outpatient visit est', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99214 - Office/outpatient visit est', '99214', 'Office/outpatient visit est', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.ProcedureCode
(ProcedureCodePlusDescription, ProcedureCode, ProcedureCodeDescription, ProcedureCodeCategory, ProcedureCodeActiveFlag, ProcedureCodeSourceSystem, ProcedureCodeSourceKey, ProcedureCodeLastUpdatedDate)
VALUES ('99215 - Office/outpatient visit est', '99215', 'Office/outpatient visit est', 'E/M', 'Y', 'EMR', -1, CAST(SYSDATETIME() AS DATE));




--	Create Provider dimension
CREATE TABLE
	dim.Provider
(
	ProviderKey					INT IDENTITY(1, 1),
	ProviderName				VARCHAR(20) NOT NULL,
	ProviderNumber				INT NOT NULL,
	ProviderType				VARCHAR(5) NOT NULL,
	ProviderSpecialty			VARCHAR(20) NOT NULL,
	ProviderActiveFlag			CHAR(1) NOT NULL,
	ProviderSourceSystem		VARCHAR(10) NOT NULL,
	ProviderSourceKey			INT NOT NULL,
	ProviderLastUpdatedDate		DATE NOT NULL
);

ALTER TABLE dim.Provider ADD CONSTRAINT PK_Provider PRIMARY KEY (ProviderKey);


--	Populate Provider dimension
SET IDENTITY_INSERT dim.Provider ON;

INSERT INTO dim.Provider
(ProviderKey, ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES (-1, 'Unknown', 0, 'N/A', 'Unknown', 'Y', 'N/A', 1, CAST(SYSDATETIME() AS DATE));

SET IDENTITY_INSERT dim.Provider OFF;

INSERT INTO dim.Provider
(ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES ('Benton, Peter', 123, 'MD', 'Emergency Medicine', 'Y', 'EMR', 1, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Provider
(ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES ('Grey, Meredith', 234, 'MD', 'Surgery', 'Y', 'EMR', 2, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Provider
(ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES ('McCoy, Leonard', 345, 'MD', 'Cardiology', 'Y', 'EMR', 3, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Provider
(ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES ('Quinn, Michaela', 456, 'MD', 'Family Medicine', 'Y', 'EMR', 4, CAST(SYSDATETIME() AS DATE));

INSERT INTO dim.Provider
(ProviderName, ProviderNumber, ProviderType, ProviderSpecialty, ProviderActiveFlag, ProviderSourceSystem, ProviderSourceKey, ProviderLastUpdatedDate)
VALUES ('Torres, Callie', 567, 'MD', 'Orthopedics', 'Y', 'EMR', 5, CAST(SYSDATETIME() AS DATE));
