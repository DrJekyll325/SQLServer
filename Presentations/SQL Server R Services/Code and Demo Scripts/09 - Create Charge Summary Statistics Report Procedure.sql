USE [RDemo]
GO


CREATE PROCEDURE [report].[uspChargeSummary_ChargeStatistics]
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
		CalendarKey,
		TotalCharges
	)
	AS
	(
		SELECT
			Chg.ChargePostingDateKey,
			TotalCharges = SUM(Chg.ChargeAmount)
		FROM
			RDemo.fact.Charges Chg
				INNER JOIN
			RDemo.dim.Calendar ChgPost
				On Chg.ChargePostingDateKey = ChgPost.CalendarKey
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
			Chg.ChargePostingDateKey BETWEEN @StatisticsStartDateKey AND @StatisticsEndDateKey
		GROUP BY
			Chg.ChargePostingDateKey
	)
	SELECT
		Cal.CalendarDate,
		TotalCharges = ISNULL(Summ.TotalCharges, 0)
	INTO
		#Charges
	FROM
		RDemo.dim.Calendar Cal
			LEFT JOIN
		Summary Summ
			ON Cal.CalendarKey = Summ.CalendarKey
	WHERE
		Cal.CalendarKey BETWEEN @StatisticsStartDateKey AND @StatisticsEndDateKey;


	DECLARE
		@InputQuery		NVARCHAR(500),
		@RScript		NVARCHAR(500);

	SET @InputQuery = N'SELECT * FROM #Charges WHERE TotalCharges > 0 AND DATEPART(dw, CalendarDate) BETWEEN 2 AND 6;';

	SET @RScript = N'
	df <- as.data.frame(c(
		mean(myQuery$TotalCharges),
		sd(myQuery$TotalCharges),
		mean(myQuery$TotalCharges) + 2 * sd(myQuery$TotalCharges),
		mean(myQuery$TotalCharges) - 2 * sd(myQuery$TotalCharges)));
	Results <- as.data.frame(t(df))
	';

	EXEC sp_execute_external_script
		@language			= N'R',
		@script				= @RScript,
		@input_data_1		= @InputQuery,
		@input_data_1_name	= N'myQuery',
		@output_data_1_name	= N'Results'
	WITH RESULT SETS
	((
		"Mean"				NUMERIC(16, 4) NOT NULL,
		"StandardDeviation"	NUMERIC(16, 4) NOT NULL,
		"PlusTwoSigma"		NUMERIC(16, 4) NOT NULL,
		"MinusTwoSigma"		NUMERIC(16, 4) NOT NULL
	));

		DROP TABLE #Charges;

END;

GO


