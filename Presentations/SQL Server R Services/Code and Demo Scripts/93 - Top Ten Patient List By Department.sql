USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspTopTenPatientListByDepartment')
	DROP PROCEDURE report.uspTopTenPatientListByDepartment;
GO


CREATE PROCEDURE report.uspTopTenPatientListByDepartment
(
	@Department		VARCHAR(20)
)
AS
BEGIN

	SELECT TOP 10
		Pat.PatientKey,
		Pat.PatientName,
		AppointmentCount = COUNT(Appt.AppointmentKey)
	FROM
		fact.Appointment Appt
			INNER JOIN
		dim.Department Dept
			ON Appt.DepartmentKey = Dept.DepartmentKey
			INNER JOIN
		dim.Patient Pat
			ON Appt.PatientKey = Pat.PatientKey
	WHERE
		Dept.Department = @Department
	GROUP BY
		Pat.PatientKey,
		Pat.PatientName
	ORDER BY
		AppointmentCount DESC,
		Pat.PatientName;

END;
