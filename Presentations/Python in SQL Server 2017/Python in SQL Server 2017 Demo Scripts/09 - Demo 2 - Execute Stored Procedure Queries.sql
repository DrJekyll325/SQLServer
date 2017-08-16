USE PyDemo;
GO


EXEC report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1,
	@DaysToLookBack	= 30;


EXEC report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= -1;


EXEC report.uspChargeSummary
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3,
	@DaysToLookBack	= 60;


EXEC report.uspChargeSummary_ChargeStatistics
	@PracticeName	= '<All Practices>',
	@DepartmentName	= '<All Departments>',
	@ProviderKey	= 3;
