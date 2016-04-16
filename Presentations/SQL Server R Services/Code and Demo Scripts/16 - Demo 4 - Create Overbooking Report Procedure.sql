USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspOverbooking')
	DROP PROCEDURE report.uspOverbooking;
GO


CREATE PROCEDURE report.uspOverbooking
(
	@PracticeName				VARCHAR(20),
	@DepartmentName				VARCHAR(20),
	@ProviderKey				INT,
	@AppointmentStartDate		DATE,
	@AppointmentEndDate			DATE,
	@OverbookingThreshold		DECIMAL(8, 4)
)
AS
BEGIN

	--	Fix incorrect parameters
	IF @OverbookingThreshold > 1
		SET @OverbookingThreshold = @OverbookingThreshold / 100;


	IF @AppointmentStartDate <= CAST(SYSDATETIME() AS DATE)
		SET @AppointmentStartDate = CAST(SYSDATETIME() AS DATE);


	IF @AppointmentEndDate <= CAST(SYSDATETIME() AS DATE)
		SET @AppointmentEndDate = CAST(SYSDATETIME() AS DATE);


	DECLARE
		@AppointmentStartDateKey	INT,
		@AppointmentEndDateKey		INT,
		@StatisticsStartDate		DATE,
		@StatisticsStartDateKey		INT,
		@StatisticsEndDate			DATE,
		@StatisticsEndDateKey		INT;


	SET @AppointmentStartDateKey = RDemo.dbo.ufnCalendarDateKey(@AppointmentStartDate);
	SET @AppointmentEndDateKey = RDemo.dbo.ufnCalendarDateKey(@AppointmentEndDate);

	SET @StatisticsStartDate = DATEADD(dd, -180, CAST(SYSDATETIME() AS DATE));
	SET @StatisticsEndDate = DATEADD(dd, -1, CAST(SYSDATETIME() AS DATE));

	SET @StatisticsStartDateKey = RDemo.dbo.ufnCalendarDateKey(@StatisticsStartDate);
	SET @StatisticsEndDateKey = RDemo.dbo.ufnCalendarDateKey(@StatisticsEndDate);

	
	IF EXISTS(SELECT * FROM sys.tables WHERE name = 'tmpAppointments')
		DROP TABLE RDemo.dbo.tmpAppointments;


	WITH Summary
	(
		ProviderKey,
		AppointmentDateKey,
		TotalAppointments
	)
	AS
	(
		SELECT
			Appt.ProviderKey,
			Appt.AppointmentDateKey,
			TotalAppointments = SUM(Appt.AppointmentCount)
		FROM
			RDemo.fact.Appointment Appt
				INNER JOIN
			RDemo.dim.Department Dept
				ON Appt.DepartmentKey = Dept.DepartmentKey
				INNER JOIN
			RDemo.dim.Provider Prov
				ON Appt.ProviderKey = Prov.ProviderKey
		WHERE
			Appt.ProviderKey <> -1
			AND
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
			Appt.AppointmentDateKey BETWEEN @AppointmentStartDateKey AND @AppointmentEndDateKey
		GROUP BY
			Appt.ProviderKey,
			Appt.AppointmentDateKey
	),
	NoShow
	(
		ProviderKey,
		NoShowRate
	)
	AS
	(
		SELECT
			Appt.ProviderKey,
			NoShowRate = CAST(SUM(Appt.NoShowAppointmentCount) AS DECIMAL(16, 4)) / CAST(SUM(Appt.AppointmentCount) AS DECIMAL(16, 4))
		FROM
			RDemo.fact.Appointment Appt
				INNER JOIN
			RDemo.dim.Department Dept
				On Appt.DepartmentKey = Dept.DepartmentKey
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
		Summ.ProviderKey,
		Summ.AppointmentDateKey,
		Summ.TotalAppointments,
		ShowUpRate = 1 - ISNULL(Nos.NoShowRate, 0),
		ExpectedAppointments = 0,
		OverbookingThreshold = @OverbookingThreshold,
		AppointmentsPerDay = ISNULL(Prov.AppointmentsPerDay, 0),
		OverbookingSlotsAllowed = 0
	INTO
		RDemo.dbo.tmpAppointments
	FROM
		Summary Summ
			LEFT JOIN
		NoShow Nos
			ON Summ.ProviderKey = Nos.ProviderKey
			LEFT JOIN
		RDemo.dim.Provider Prov
			ON Summ.ProviderKey = Prov.ProviderKey
	ORDER BY
		ProviderKey,
		AppointmentDateKey;



	DECLARE
		@InputQuery		NVARCHAR(500),
		@RScript		NVARCHAR(500);

	SET @InputQuery = N'
	SELECT
		ProviderKey,
		AppointmentDateKey,
		TotalAppointments,
		ShowUpRate,
		ExpectedAppointments,
		OverbookingThreshold,
		AppointmentsPerDay,
		OverbookingSlotsAllowed
	FROM
		Rdemo.dbo.tmpAppointments;';


	SET @RScript = N'
	df <- myQuery;
	df$ExpectedAppointments <- qbinom(p = df$OverbookingThreshold, size = df$TotalAppointments, prob = df$ShowUpRate, lower.tail = TRUE);
	df$OverbookingSlotsAllowed <- df$TotalAppointments - df$ExpectedAppointments;
	Results <- df;
	';


	SELECT
		*
	INTO
		#tmpOverbooking
	FROM
		OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
			EXEC sp_execute_external_script
				@language			= N''R'',
				@script				= N''
					df <- myQuery;
					df$ExpectedAppointments <- qbinom(p = df$OverbookingThreshold, size = df$TotalAppointments, prob = df$ShowUpRate, lower.tail = TRUE);
					df$OverbookingSlotsAllowed <- df$TotalAppointments - df$ExpectedAppointments;
					Results <- df;'',
				@input_data_1		= N''
					SELECT
						ProviderKey,
						AppointmentDateKey,
						TotalAppointments,
						ShowUpRate,
						ExpectedAppointments,
						OverbookingThreshold,
						AppointmentsPerDay,
						OverbookingSlotsAllowed
					FROM
						Rdemo.dbo.tmpAppointments;'',
				@input_data_1_name	= N''myQuery'',
				@output_data_1_name	= N''Results''
			WITH RESULT SETS
			((
		"ProviderKey"				INT NOT NULL,
		"AppointmentDateKey"		INT NOT NULL,
		"TotalAppointments"			INT NOT NULL,
		"ShowUpRate"				NUMERIC(6, 4) NOT NULL,
		"ExpectedAppointments"		INT NOT NULL,
		"OverbookingThreshold"		NUMERIC(6, 4)  NOT NULL,
		"AppointmentsPerDay"		INT NOT NULL,
		"OverbookingSlotsAllowed"	INT NOT NULL
			));');


	SELECT
		Prov.ProviderName,
		Prov.ProviderSpecialty,
		AppointmentDate = Cal.CalendarDate,
		Ovr.TotalAppointments,
		Ovr.ShowUpRate,
		Ovr.ExpectedAppointments,
		Ovr.OverbookingThreshold,
		Ovr.AppointmentsPerDay,
		Ovr.OverbookingSlotsAllowed,
		TotalFreeSlots = Ovr.AppointmentsPerDay - Ovr.TotalAppointments + Ovr.OverbookingSlotsAllowed
	FROM
		#tmpOverbooking Ovr
			INNER JOIN
		RDemo.dim.Provider Prov
			ON Ovr.ProviderKey = Prov.ProviderKey
			INNER JOIN
		RDemo.dim.Calendar Cal
			ON Ovr.AppointmentDateKey = Cal.CalendarKey;

	DROP TABLE RDemo.dbo.tmpAppointments;
	DROP TABLE #tmpOverbooking;

END;

GO


