USE PyDemo;
GO


--	Create and populate Charges fact
IF EXISTS(SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'fact') AND name = 'Charges')
	DROP TABLE fact.Charges;


CREATE TABLE
	fact.Charges
(
	ChargesKey					INT IDENTITY(1, 1),
	ChargePostingDateKey		INT NOT NULL,
	DepartmentKey				INT NOT NULL,
	PatientKey					INT NOT NULL,
	ProcedureCodeKey			INT NOT NULL,
	ProviderKey					INT NOT NULL,
	ServiceDateKey				INT NOT NULL,
	ChargeAmount				DECIMAL(12, 2) NOT NULL,
	MalpracticeRVUs				DECIMAL(12, 2) NOT NULL,
	PracticeExpenseRVUs			DECIMAL(12, 2) NOT NULL,
	ProcedureCount				SMALLINT NOT NULL,
	TotalRVUs					DECIMAL(12, 2) NOT NULL,
	WorkRVUs					DECIMAL(12, 2) NOT NULL,
	Units						SMALLINT NOT NULL,
	ChargesSourceSystem			VARCHAR(10) NOT NULL,
	ChargesSourceKey			INT NOT NULL,
	ChargesLastUpdatedDate		DATE NOT NULL
);

ALTER TABLE fact.Charges ADD CONSTRAINT PK_Charges PRIMARY KEY (ChargesKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_ChargePostingDate FOREIGN KEY (ChargePostingDateKey)
REFERENCES dim.Calendar (CalendarKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_Department FOREIGN KEY (DepartmentKey)
REFERENCES dim.Department (DepartmentKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_Patient FOREIGN KEY (PatientKey)
REFERENCES dim.Patient (PatientKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_Provider FOREIGN KEY (ProviderKey)
REFERENCES dim.Provider (ProviderKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_ProcedureCode FOREIGN KEY (ProcedureCodeKey)
REFERENCES dim.ProcedureCode (ProcedureCodeKey);

ALTER TABLE fact.Charges ADD CONSTRAINT FK_Charges_ServiceDate FOREIGN KEY (ServiceDateKey)
REFERENCES dim.Calendar (CalendarKey);


DECLARE
	@LastBusinessDay		DATE,
	@LastBusinessDayKey		INT,
	@180DaysAgo				DATE,
	@180DaysAgoKey			INT;

SET @LastBusinessDay = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

IF DATEPART(WEEKDAY, @LastBusinessDay) = 7
	SET @LastBusinessDay = DATEADD(dd, -1, @LastBusinessDay);

IF DATEPART(WEEKDAY, @LastBusinessDay) = 1
	SET @LastBusinessDay = DATEADD(dd, -2, @LastBusinessDay);

SET @LastBusinessDayKey = RDemo.dbo.ufnCalendarDateKey(@LastBusinessDay);
SET @180DaysAgo = DATEADD(dd, -179, @LastBusinessDay);
SET @180DaysAgoKey = RDemo.dbo.ufnCalendarDateKey(@180DaysAgo);


CREATE TABLE
	#tmpCharges
(
	PK_Charges		INT IDENTITY(1, 1) PRIMARY KEY,
	ChargeAmount	DECIMAL(12, 2)
);

INSERT INTO
	#tmpCharges
(
	ChargeAmount
)
SELECT
	ChargeAmount
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''Python'',
			@script				= N''import numpy as np
import pandas as pd
from scipy.stats import norm

np.random.seed(seed = 25625)
myMean = 500000
mySD = 50000

r = norm.rvs(loc = myMean, scale = mySD, size = 178)
r = np.append(r, [587750, 412250])
Results = pd.DataFrame(r)'',
			@input_data_1		= N'''',
			@input_data_1_name	= N''myQuery'',
			@output_data_1_name	= N''Results''
		WITH RESULT SETS
		((
			"ChargeAmount"	DECIMAL(12, 2) NOT NULL
		));');


WITH Dates
(
	DayNumber,
	CalendarKey,
	DayOfWeekNum
)
AS
(
	SELECT
		DayNumber = ROW_NUMBER() OVER (ORDER BY Cal.CalendarKey),
		Cal.CalendarKey,
		Cal.DayOfWeekNum
	FROM
		RDemo.dim.Calendar Cal
	WHERE
		Cal.CalendarKey BETWEEN @180DaysAgoKey AND @LastBusinessDayKey
)
SELECT
	Dates.CalendarKey,
	NumberOfEncounters = FLOOR(	CASE
									WHEN Dates.DayOfWeekNum = 7 THEN Chg.ChargeAmount / 10
									ELSE Chg.ChargeAmount
								END / 250)
INTO
	#tmpEncounters
FROM
	#tmpCharges Chg
		INNER JOIN
	Dates
		ON Chg.PK_Charges = Dates.DayNumber
WHERE
	Dates.DayOfWeekNum <> 1;


INSERT INTO
	fact.Charges
(
	ChargePostingDateKey,
	DepartmentKey,
	PatientKey,
	ProcedureCodeKey,
	ProviderKey,
	ServiceDateKey,
	ChargeAmount,
	MalpracticeRVUs,
	PracticeExpenseRVUs,
	ProcedureCount,
	TotalRVUs,
	WorkRVUs,
	Units,
	ChargesSourceSystem,
	ChargesSourceKey,
	ChargesLastUpdatedDate
)
SELECT
	ChargePostingDateKey = Enc.CalendarKey,
	DepartmentKey = -1,
	PatientKey = ABS(CHECKSUM(NEWID()) % 10000) + 1,
	ProcedureCodeKey = -1,
	ProviderKey = ABS(CHECKSUM(NEWID()) % 5) + 1,
	ServiceDateKey = Enc.CalendarKey,
	ChargeAmount = 250,
	MalpracticeRVU = 0,
	PracticeExpenseRVUs = 0,
	ProcedureCount = 1,
	TotalRVUs = 1,
	WorkRVUs = 1,
	Units = 1,
	ChargesSourceSystem = 'EMR',
	ChargesSourceKey = t.SequenceNumber,
	ChargesLastUpdatedDate = CAST(SYSDATETIME() AS DATE)
FROM
	#tmpEncounters Enc
		CROSS JOIN
	Admin.dbo.Tally t
WHERE
	t.SequenceNumber <= Enc.NumberOfEncounters
ORDER BY
	Enc.CalendarKey,
	t.SequenceNumber;


UPDATE
	fact.Charges
SET
	DepartmentKey =	CASE
						WHEN ProviderKey = 1 THEN 20
						WHEN ProviderKey = 2 THEN 23
						WHEN ProviderKey = 3 THEN	CASE
														WHEN ChargesSourceKey % 2 = 0 THEN 18
														WHEN ChargesSourceKey % 2 = 1 THEN 19
													END
						WHEN ProviderKey = 4 THEN (ChargesSourceKey % 5 + 1)
						WHEN ProviderKey = 5 THEN 22
					END,
	ProcedureCodeKey = (ChargesSourceKey % 10 + 1),
	WorkRVUs =	CASE
					WHEN (ChargesSourceKey % 10 + 1) = 1 THEN 0.48
					WHEN (ChargesSourceKey % 10 + 1) = 2 THEN 0.97
					WHEN (ChargesSourceKey % 10 + 1) = 3 THEN 1.42
					WHEN (ChargesSourceKey % 10 + 1) = 4 THEN 2.43
					WHEN (ChargesSourceKey % 10 + 1) = 5 THEN 3.17
					WHEN (ChargesSourceKey % 10 + 1) = 6 THEN 0.18
					WHEN (ChargesSourceKey % 10 + 1) = 7 THEN 0.48
					WHEN (ChargesSourceKey % 10 + 1) = 8 THEN 0.97
					WHEN (ChargesSourceKey % 10 + 1) = 9 THEN 1.50
					WHEN (ChargesSourceKey % 10 + 1) = 10 THEN 2.11
				END;


UPDATE
	fact.Charges
SET
	TotalRVUs = WorkRVUs;


DROP TABLE #tmpCharges;
DROP TABLE #tmpEncounters;
