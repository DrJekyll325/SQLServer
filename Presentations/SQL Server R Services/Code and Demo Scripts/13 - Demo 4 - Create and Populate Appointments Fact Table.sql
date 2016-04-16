USE RDemo;
GO


--	Create and populate Appointment fact
IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Appointment')
	DROP TABLE fact.Appointment;


CREATE TABLE
	fact.Appointment
(
	AppointmentKey					INT IDENTITY(1, 1),
	AppointmentDateKey				INT NOT NULL,
	CancelledDateKey				INT NOT NULL,
	CompletedDateKey				INT NOT NULL,
	DepartmentKey					INT NOT NULL,
	NoShowDateKey					INT NOT NULL,
	PatientKey						INT NOT NULL,
	ProcedureCodeKey				INT NOT NULL,
	ProviderKey						INT NOT NULL,
	AppointmentCount				SMALLINT NOT NULL,
	CancelledAppointmentCount		SMALLINT NOT NULL,
	CompletedAppointmentCount		SMALLINT NOT NULL,
	NoShowAppointmentCount			SMALLINT NOT NULL,
	AppointmentSourceSystem			VARCHAR(10) NOT NULL,
	AppointmentSourceKey			INT NOT NULL,
	AppointmentLastUpdatedDate		DATE NOT NULL
);

ALTER TABLE fact.Appointment ADD CONSTRAINT PK_Appointment PRIMARY KEY (AppointmentKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_AppointmentDate FOREIGN KEY (AppointmentDateKey)
REFERENCES dim.Calendar (CalendarKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_CancelledDate FOREIGN KEY (CancelledDateKey)
REFERENCES dim.Calendar (CalendarKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_CompletedDate FOREIGN KEY (CompletedDateKey)
REFERENCES dim.Calendar (CalendarKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_Department FOREIGN KEY (DepartmentKey)
REFERENCES dim.Department (DepartmentKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_NoShowDate FOREIGN KEY (NoShowDateKey)
REFERENCES dim.Calendar (CalendarKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_Patient FOREIGN KEY (PatientKey)
REFERENCES dim.Patient (PatientKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_Provider FOREIGN KEY (ProviderKey)
REFERENCES dim.Provider (ProviderKey);

ALTER TABLE fact.Appointment ADD CONSTRAINT FK_Appointment_ProcedureCode FOREIGN KEY (ProcedureCodeKey)
REFERENCES dim.ProcedureCode (ProcedureCodeKey);



DECLARE
	@LastBusinessDay		DATE,
	@LastBusinessDayKey		INT,
	@180DaysAgo				DATE,
	@180DaysAgoKey			INT,
	@180DaysFromNow			DATE,
	@180DaysFromNowKey		INT;


SET @LastBusinessDay = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

IF DATEPART(WEEKDAY, @LastBusinessDay) = 7
	SET @LastBusinessDay = DATEADD(dd, -1, @LastBusinessDay);

IF DATEPART(WEEKDAY, @LastBusinessDay) = 1
	SET @LastBusinessDay = DATEADD(dd, -2, @LastBusinessDay);

SET @LastBusinessDayKey = RDemo.dbo.ufnCalendarDateKey(@LastBusinessDay);

SET @180DaysAgo = DATEADD(dd, -179, @LastBusinessDay);
SET @180DaysAgoKey = RDemo.dbo.ufnCalendarDateKey(@180DaysAgo);

SET @180DaysFromNow = DATEADD(dd, 180, @LastBusinessDay);
SET @180DaysFromNowKey = RDemo.dbo.ufnCalendarDateKey(@180DaysFromNow);


CREATE TABLE
	#tmpBuildAppointments
(
	ProviderKey			INT NOT NULL PRIMARY KEY,
	ProviderName		VARCHAR(20) NOT NULL,
	ProviderSpecialty	VARCHAR(20) NOT NULL,
	AppointmentsPerDay	INT NOT NULL,
	NoShowRate			DECIMAL(6, 4) NOT NULL
);

INSERT INTO #tmpBuildAppointments (ProviderKey,	ProviderName, ProviderSpecialty, AppointmentsPerDay, NoShowRate)
VALUES (1, 'Benton, Peter', 'Emergency Medicine', 0, 0.0000),
	(2, 'Grey, Meredith', 'Surgery', 8, 0.0500),
	(3, 'McCoy, Leonard', 'Cardiology', 16, 0.1000),
	(4, 'Quinn, Michaela', 'Family Medicine', 32, 0.2500),
	(5, 'Torres, Callie', 'Orthopedics', 24, 0.1500);


WITH Dates
(
	DayNumber,
	CalendarKey
)
AS
(
	SELECT
		DayNumber = ROW_NUMBER() OVER (ORDER BY Cal.CalendarKey),
		Cal.CalendarKey
	FROM
		RDemo.dim.Calendar Cal
	WHERE
		Cal.CalendarKey BETWEEN @180DaysAgoKey AND @180DaysFromNowKey
		AND
		Cal.DayOfWeekNum BETWEEN 2 AND 6
)
INSERT INTO
	fact.Appointment
(
	AppointmentDateKey,
	CancelledDateKey,
	CompletedDateKey,
	DepartmentKey,
	NoShowDateKey,
	PatientKey,
	ProcedureCodeKey,
	ProviderKey,
	AppointmentCount,
	CancelledAppointmentCount,
	CompletedAppointmentCount,
	NoShowAppointmentCount,
	AppointmentSourceSystem,
	AppointmentSourceKey,
	AppointmentLastUpdatedDate
)
SELECT
	AppointmentDateKey = Dates.CalendarKey,
	CancelledDateKey = -1,
	CompletedDateKey = -1,
	DepartmentKey = -1,
	NoShowDateKey = -1,
	PatientKey = ABS(CHECKSUM(NEWID()) % 10000) + 1,
	ProcedureCodeKey = -1,
	ProviderKey = Appt.ProviderKey,
	AppointmentCount = 1,
	CancelledAppointmentCount = 0,
	CompletedAppointmentCount = 0,
	NoShowAppointmentCount = 0,
	AppointmentSourceSystem = 'EMR',
	AppointmentSourceKey = t.SequenceNumber,
	AppointmentLastUpdatedDate = CAST(SYSDATETIME() AS DATE)
FROM
	Dates
		CROSS JOIN
	#tmpBuildAppointments Appt
		CROSS JOIN
	Admin.dbo.Tally t
WHERE
	t.SequenceNumber <= Appt.AppointmentsPerDay
ORDER BY
	Dates.CalendarKey,
	Appt.ProviderKey,
	t.SequenceNumber;


UPDATE
	Fact
SET
	DepartmentKey =	CASE
						WHEN Appt.ProviderKey = 1 THEN 20
						WHEN Appt.ProviderKey = 2 THEN 23
						WHEN Appt.ProviderKey = 3 THEN	CASE
														WHEN AppointmentSourceKey % 2 = 0 THEN 18
														WHEN AppointmentSourceKey % 2 = 1 THEN 19
													END
						WHEN Appt.ProviderKey = 4 THEN (AppointmentSourceKey % 5 + 1)
						WHEN Appt.ProviderKey = 5 THEN 22
					END,
	NoShowDateKey =	CASE
						WHEN AppointmentDateKey <= @LastBusinessDayKey
							AND ((ABS(CHECKSUM(NEWID()) % 10000.0000) + 1.0000) / 10000.0000) <= Appt.NoShowRate THEN AppointmentDateKey
						ELSE -1
					END
FROM
	Fact.Appointment Fact
		INNER JOIN
	#tmpBuildAppointments Appt
		ON Fact.ProviderKey = Appt.ProviderKey;


UPDATE
	Fact
SET
	CompletedDateKey =	CASE
							WHEN AppointmentDateKey <= @LastBusinessDayKey AND Fact.NoShowDateKey = -1 THEN AppointmentDateKey
							ELSE -1
						END,
	CompletedAppointmentCount =	CASE
									WHEN AppointmentDateKey <= @LastBusinessDayKey AND Fact.NoShowDateKey = -1 THEN 1
									ELSE 0
								END,
	NoShowAppointmentCount =	CASE
									WHEN AppointmentDateKey <= @LastBusinessDayKey AND Fact.NoShowDateKey > -1 THEN 1
									ELSE 0
								END
FROM
	Fact.Appointment Fact;


WITH RowsToDelete
(
	AppointmentKey,
	DeleteFlag
)
AS
(
	SELECT
		AppointmentKey,
		DeleteFlag =	CASE
							WHEN ((ABS(CHECKSUM(NEWID()) % 10000.0000) + 1.0000) / 10000.0000) < 0.1500 THEN 1
							ELSE 0
						END
	FROM
		Fact.Appointment
)
DELETE
	Fact
FROM
	Fact.Appointment Fact
		INNER JOIN
	RowsToDelete Del
		ON Fact.AppointmentKey = Del.AppointmentKey AND Del.DeleteFlag = 1;


DROP TABLE #tmpBuildAppointments;
