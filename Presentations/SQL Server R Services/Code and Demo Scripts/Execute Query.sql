EXEC RDemo.report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3,
	@DaysToLookBack	= 30;


EXEC RDemo.report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3;


EXEC RDemo.report.uspAppointmentSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1;
