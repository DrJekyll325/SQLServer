USE PyDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspReportParameters_Practice')
	DROP PROCEDURE report.uspReportParameters_Practice;
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


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspReportParameters_Department')
	DROP PROCEDURE report.uspReportParameters_Department;
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


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspReportParameters_Provider')
	DROP PROCEDURE report.uspReportParameters_Provider;
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
