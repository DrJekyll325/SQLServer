USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspDepartmentList')
	DROP PROCEDURE report.uspDepartmentList;
GO


CREATE PROCEDURE report.uspDepartmentList
AS
BEGIN

	SELECT DISTINCT
		Dept.Department
	FROM
		dim.Department Dept
			INNER JOIN
		dim.Provider Prov
			ON Dept.Department = Prov.ProviderSpecialty
	WHERE
		Dept.DepartmentKey > 0
		AND
		Dept.DepartmentActiveFlag = 'Y'
		AND
		Prov.ProviderActiveFlag = 'Y'
	ORDER BY
		Dept.Department;

END;
