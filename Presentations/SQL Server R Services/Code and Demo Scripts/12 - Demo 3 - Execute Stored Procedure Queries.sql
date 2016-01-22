EXEC RDemo.report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1,
	@DaysToLookBack	= 30;


EXEC RDemo.report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1;


EXEC RDemo.report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3,
	@DaysToLookBack	= 60;


EXEC RDemo.report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3;
