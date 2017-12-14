USE RDemo;
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE name = 'uspProviderListByDepartment')
	DROP PROCEDURE report.uspProviderListByDepartment;
GO


CREATE PROCEDURE report.uspProviderListByDepartment
(
	@Department		VARCHAR(20)
)
AS
BEGIN

	SELECT DISTINCT
		Prov.ProviderKey,
		Prov.ProviderName,
		Prov.ProviderNumber,
		Prov.AppointmentsPerDay
	FROM
		dim.Provider Prov
	WHERE
		Prov.ProviderSpecialty = @Department
	ORDER BY
		Prov.ProviderName;

END;
