USE RDemo;
GO


CREATE PROCEDURE report.uspReportParameters_Practice
(
	@AllowSelectAllPractices	BIT
)
AS
BEGIN

	SELECT
		PracticeName = '<All Practices>'
	WHERE
		@AllowSelectAllPractices = 1

	UNION ALL

	SELECT DISTINCT
		PracticeName = Dept.Practice
	FROM
		RDemo.dim.Department Dept

	ORDER BY
		PracticeName;

END;
GO


CREATE PROCEDURE report.uspReportParameters_Department
(
	@PracticeName					VARCHAR(20),
	@AllowSelectAllDepartments		BIT
)
AS
BEGIN

	SELECT
		DepartmentName = '<All Departments>'
	WHERE
		@AllowSelectAllDepartments = 1

	UNION ALL

	SELECT DISTINCT
		DepartmentName = Dept.Department
	FROM
		RDemo.dim.Department Dept
	WHERE
		@PracticeName = '<All Practices>'
		OR
		Dept.Practice = @PracticeName

	ORDER BY
		DepartmentName;

END;
GO


CREATE PROCEDURE report.uspReportParameters_Provider
(
	@AllowSelectAllProviders	BIT
)
AS
BEGIN

	SELECT
		ProviderKey = -1,
		ProviderName = '<All Providers>'
	WHERE
		@AllowSelectAllProviders = 1

	UNION ALL

	SELECT
		ProviderKey = Prov.ProviderKey,
		ProviderName = Prov.ProviderName
	FROM
		RDemo.dim.Provider Prov

	ORDER BY
		ProviderName;

END;
GO