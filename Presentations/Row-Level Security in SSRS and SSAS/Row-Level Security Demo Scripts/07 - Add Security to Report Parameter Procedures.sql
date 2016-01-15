USE MyHospital;
GO


CREATE PROCEDURE report.uspReportParameters_Practice_WithSecurity
(
	@AllowSelectAllPractices	BIT,
	@ExecutedByUser				VARCHAR(25)
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
		MyHospital.dim.Department Dept
			INNER JOIN
		sec.UserDepartment UsrDept
			ON Dept.DepartmentKey = UsrDept.DepartmentKey AND SYSDATETIME() BETWEEN UsrDept.StartEffectiveDate AND UsrDept.EndEffectiveDate
			INNER JOIN
		sec.Users Usr
			ON UsrDept.UserKey = Usr.UserKey
	WHERE
		Usr.UserLogin = @ExecutedByUser

	ORDER BY
		PracticeName;

END;
GO


CREATE PROCEDURE report.uspReportParameters_Department_WithSecurity
(
	@PracticeName					VARCHAR(20),
	@AllowSelectAllDepartments		BIT,
	@ExecutedByUser					VARCHAR(25)
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
		MyHospital.dim.Department Dept
			INNER JOIN
		sec.UserDepartment UsrDept
			ON Dept.DepartmentKey = UsrDept.DepartmentKey AND SYSDATETIME() BETWEEN UsrDept.StartEffectiveDate AND UsrDept.EndEffectiveDate
			INNER JOIN
		sec.Users Usr
			ON UsrDept.UserKey = Usr.UserKey
	WHERE
		(@PracticeName = '<All Practices>'
			OR
			Dept.Practice = @PracticeName)
		AND
		Usr.UserLogin = @ExecutedByUser

	ORDER BY
		DepartmentName;

END;
GO
