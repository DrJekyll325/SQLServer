USE MyHospital;
GO


CREATE PROCEDURE report.uspChargeSummary
(
	@PracticeName				VARCHAR(20),
	@DepartmentName				VARCHAR(20),
	@ProviderKey				INT,
	@ChargePostingStartDate		DATE,
	@ChargePostingStartEnd		DATE
)
AS
BEGIN

	SELECT
		Dept.Practice,
		Dept.Department,
		Dept.Clinic,
		Prov.ProviderName,
		TotalProcedures = SUM(Chg.ProcedureCount),
		TotalCharges = SUM(Chg.ChargeAmount),
		TotalRVUs = SUM(Chg.TotalRVUs)
	FROM
		MyHospital.fact.Charges Chg
			INNER JOIN
		MyHospital.dim.Calendar ChgPost
			On Chg.ChargePostingDateKey = ChgPost.CalendarKey
			INNER JOIN
		MyHospital.dim.Department Dept
			On Chg.DepartmentKey = Dept.DepartmentKey
			INNER JOIN
		MyHospital.dim.ProcedureCode Prc
			On Chg.ProcedureCodeKey = Prc.ProcedureCodeKey
			INNER JOIN
		MyHospital.dim.Provider Prov
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
		TRY_CONVERT(DATE, ChgPost.CalendarDate, 120) BETWEEN @ChargePostingStartDate AND @ChargePostingStartEnd
	GROUP BY
		Dept.Practice,
		Dept.Department,
		Dept.Clinic,
		Prov.ProviderName
	ORDER BY
		Dept.Practice,
		Dept.Department,
		Dept.Clinic,
		Prov.ProviderName;

END;
