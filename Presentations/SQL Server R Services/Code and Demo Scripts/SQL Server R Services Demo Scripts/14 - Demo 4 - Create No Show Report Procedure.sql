USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspAppointmentSummary')
	DROP PROCEDURE report.uspAppointmentSummary;
GO


CREATE PROCEDURE report.uspAppointmentSummary
(
	@PracticeName				VARCHAR(20),
	@DepartmentName				VARCHAR(20),
	@ProviderKey				INT
)
AS
BEGIN

	DECLARE
		@StatisticsStartDate		DATE,
		@StatisticsStartDateKey		INT,
		@StatisticsEndDate			DATE,
		@StatisticsEndDateKey		INT;


	SET @StatisticsStartDate = DATEADD(dd, -180, CAST(SYSDATETIME() AS DATE));
	SET @StatisticsEndDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

	SET @StatisticsStartDateKey = RDemo.dbo.ufnCalendarDateKey(@StatisticsStartDate);
	SET @StatisticsEndDateKey = RDemo.dbo.ufnCalendarDateKey(@StatisticsEndDate);


	WITH Summary
	(
		ProviderKey,
		TotalAppointments,
		TotalCompletedAppointments,
		TotalNoShowAppointments,
		NoShowRate
	)
	AS
	(
		SELECT
			Appt.ProviderKey,
			TotalAppointments = SUM(Appt.AppointmentCount),
			TotalCompletedAppointments = SUM(Appt.CompletedAppointmentCount),
			TotalNoShowAppointments = SUM(Appt.NoShowAppointmentCount),
			NoShowRate = CAST(SUM(Appt.NoShowAppointmentCount) AS DECIMAL(16, 4)) / CAST(SUM(Appt.AppointmentCount) AS DECIMAL(16, 4))
		FROM
			RDemo.fact.Appointment Appt
				INNER JOIN
			RDemo.dim.Department Dept
				On Appt.DepartmentKey = Dept.DepartmentKey
				INNER JOIN
			RDemo.dim.ProcedureCode Prc
				On Appt.ProcedureCodeKey = Prc.ProcedureCodeKey
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
				Appt.ProviderKey = @ProviderKey)
			AND
			Appt.AppointmentDateKey BETWEEN @StatisticsStartDateKey AND @StatisticsEndDateKey
		GROUP BY
			Appt.ProviderKey
	)
	SELECT
		Prov.ProviderKey,
		Prov.ProviderName,
		Prov.ProviderSpecialty,
		TotalAppointments = ISNULL(Summ.TotalAppointments, 0),
		TotalCompletedAppointments = ISNULL(Summ.TotalCompletedAppointments, 0),
		TotalNoShowAppointments = ISNULL(Summ.TotalNoShowAppointments, 0),
		NoShowRate = ISNULL(Summ.NoShowRate, 0),
		Prov.AppointmentsPerDay
	FROM
		RDemo.dim.Provider Prov
			LEFT JOIN
		Summary Summ
			ON Prov.ProviderKey = Summ.ProviderKey
	WHERE
		Prov.ProviderKey <> -1
	ORDER BY
		Prov.ProviderName;

END;

GO


