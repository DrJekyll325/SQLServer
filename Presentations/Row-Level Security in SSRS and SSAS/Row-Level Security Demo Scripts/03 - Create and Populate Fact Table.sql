USE MyHospital;
GO


--	Create and populate Charges fact
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
	ChargePostingDateKey = dbo.ufnCalendarDateKey(CAST(DATEADD(dd, ABS(CHECKSUM(NEWID()) % 1826), '2011-04-01') AS DATE)),
	DepartmentKey = -1,
	PatientKey = ABS(CHECKSUM(NEWID()) % 10000) + 1,
	ProcedureCodeKey = -1,
	ProviderKey = ABS(CHECKSUM(NEWID()) % 5) + 1,
	ServiceDateKey = -1,
	ChargeAmount = 100,
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
	MyHospital.dbo.Tally t
ORDER BY
	t.SequenceNumber;

UPDATE
	fact.Charges
SET
	ServiceDateKey = ChargePostingDateKey;


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
	ChargeAmount =	CASE
						WHEN (ChargesSourceKey % 10 + 1) = 1 THEN 43.00
						WHEN (ChargesSourceKey % 10 + 1) = 2 THEN 75.00
						WHEN (ChargesSourceKey % 10 + 1) = 3 THEN 108.00
						WHEN (ChargesSourceKey % 10 + 1) = 4 THEN 166.00
						WHEN (ChargesSourceKey % 10 + 1) = 5 THEN 207.00
						WHEN (ChargesSourceKey % 10 + 1) = 6 THEN 20.00
						WHEN (ChargesSourceKey % 10 + 1) = 7 THEN 44.00
						WHEN (ChargesSourceKey % 10 + 1) = 8 THEN 73.00
						WHEN (ChargesSourceKey % 10 + 1) = 9 THEN 108.00
						WHEN (ChargesSourceKey % 10 + 1) = 10 THEN 144.00
					END,
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
