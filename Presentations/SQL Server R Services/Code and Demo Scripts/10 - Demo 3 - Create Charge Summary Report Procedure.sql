USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspChargeSummary')
	DROP PROCEDURE report.uspChargeSummary;
GO


CREATE PROCEDURE report.uspChargeSummary
(
	@PracticeName				VARCHAR(20),
	@DepartmentName				VARCHAR(20),
	@ProviderKey				INT,
	@DaysToLookBack				INT = 30
)
AS
BEGIN

	DECLARE
		@ChargePostingStartDate		DATE,
		@ChargePostingStartDateKey	INT,
		@ChargePostingEndDate		DATE,
		@ChargePostingEndDateKey	INT;


	SET @ChargePostingStartDate = DATEADD(dd, -1 * @DaysToLookBack, CAST(SYSDATETIME() AS DATE));
	SET @ChargePostingEndDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

	SET @ChargePostingStartDateKey = RDemo.dbo.ufnCalendarDateKey(@ChargePostingStartDate);
	SET @ChargePostingEndDateKey = RDemo.dbo.ufnCalendarDateKey(@ChargePostingEndDate);


	WITH Summary
	(
		CalendarKey,
		TotalProcedures,
		TotalCharges,
		TotalRVUs
	)
	AS
	(
		SELECT
			Chg.ChargePostingDateKey,
			TotalProcedures = SUM(Chg.ProcedureCount),
			TotalCharges = SUM(Chg.ChargeAmount),
			TotalRVUs = SUM(Chg.TotalRVUs)
		FROM
			RDemo.fact.Charges Chg
				INNER JOIN
			RDemo.dim.Department Dept
				On Chg.DepartmentKey = Dept.DepartmentKey
				INNER JOIN
			RDemo.dim.ProcedureCode Prc
				On Chg.ProcedureCodeKey = Prc.ProcedureCodeKey
				INNER JOIN
			RDemo.dim.Provider Prov
				On Chg.ProviderKey = Prov.ProviderKey
		WHERE
			(@PracticeName = '<All Practices>'
				OR
				Dept.Practice = @PracticeName)
			AND
			(@DepartmentName = '<All Departments>'
				OR
				Dept.Department = @DepartmentName)
			AND
			(@ProviderKey = -1
				OR
				Chg.ProviderKey = @ProviderKey)
			AND
			Chg.ChargePostingDateKey BETWEEN @ChargePostingStartDateKey AND @ChargePostingEndDateKey
		GROUP BY
			Chg.ChargePostingDateKey
	)
	SELECT
		ChargePostingDate = TRY_CONVERT(DATE, Cal.CalendarDate, 120),
		TotalProcedures = ISNULL(Summ.TotalProcedures, 0),
		TotalCharges = ISNULL(Summ.TotalCharges, 0),
		TotalRVUs = ISNULL(Summ.TotalRVUs, 0)
	FROM
		RDemo.dim.Calendar Cal
			LEFT JOIN
		Summary Summ
			ON Cal.CalendarKey = Summ.CalendarKey
	WHERE
		Cal.CalendarKey BETWEEN @ChargePostingStartDateKey AND @ChargePostingEndDateKey
	ORDER BY
		Cal.CalendarDate;

END;
