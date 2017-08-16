USE PyDemo;
GO


EXEC report.uspAppointmentSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1;


EXEC report.uspOverbooking
	@PracticeName			= '<All Practices>',
	@DepartmentName			= '<All Departments>',
	@ProviderKey			= -1,
	@AppointmentStartDate	= '2017-06-19',
	@AppointmentEndDate		= '2017-06-23',
	@OverbookingThreshold	= 0.90;


EXEC report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3,
	@DaysToLookBack	= 60;


EXEC report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3;
