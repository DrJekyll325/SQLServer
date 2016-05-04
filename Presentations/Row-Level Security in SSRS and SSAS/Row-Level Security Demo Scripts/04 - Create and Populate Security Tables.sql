USE MyHospital;
GO


--	Create User table
CREATE TABLE
	sec.Users
(
	UserKey					INT IDENTITY(1, 1),
	UserName				VARCHAR(20) NOT NULL,
	UserLogin				VARCHAR(25) NOT NULL,
	AllDepartmentsFlag		CHAR(1) NOT NULL
);

ALTER TABLE sec.Users ADD CONSTRAINT PK_User PRIMARY KEY (UserKey);


--	Populate User table
INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Benton, Peter', 'MyHospital\pbenton', 'N');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Cuddy, Lisa', 'MyHospital\lcuddy', 'Y');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Grey, Meredith', 'MyHospital\mgrey', 'N');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Hyde, Chris', 'MyHospital\drjekyll325', 'Y');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('McCoy, Leonard', 'MyHospital\lmccoy', 'N');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Quinn, Michaela', 'MyHospital\mquinn', 'N');

INSERT INTO sec.Users (UserName, UserLogin, AllDepartmentsFlag)
VALUES ('Torres, Callie', 'MyHospital\ctorres', 'N');




--	Create User-Department security table
CREATE TABLE
	sec.UserDepartment
(
	UserDepartmentKey		INT IDENTITY(1, 1),
	DepartmentKey			INT NOT NULL,
	UserKey					INT NOT NULL,
	StartEffectiveDate		DATE NOT NULL,
	EndEffectiveDate		DATE NOT NULL
);

ALTER TABLE sec.UserDepartment ADD CONSTRAINT PK_UserDepartment PRIMARY KEY (UserDepartmentKey);

ALTER TABLE sec.UserDepartment ADD CONSTRAINT FK_UserDepartment_Department FOREIGN KEY (DepartmentKey)
REFERENCES dim.Department (DepartmentKey);

ALTER TABLE sec.UserDepartment ADD CONSTRAINT FK_UserDepartment_User FOREIGN KEY (UserKey)
REFERENCES sec.Users (UserKey);


--	Populate User-Department security table for people with access to all departments
INSERT INTO
	sec.UserDepartment
(
	DepartmentKey,
	UserKey,
	StartEffectiveDate,
	EndEffectiveDate
)
SELECT
	Dept.DepartmentKey,
	Usr.UserKey,
	CAST(SYSDATETIME() AS DATE),
	'2099-12-31'
FROM
	sec.Users Usr
		CROSS JOIN
	dim.Department Dept
WHERE
	Usr.AllDepartmentsFlag = 'Y';


--	Populate User-Department security table for people with access to specific departments only
INSERT INTO
	sec.UserDepartment
(
	DepartmentKey,
	UserKey,
	StartEffectiveDate,
	EndEffectiveDate
)
SELECT
	Dept.DepartmentKey,
	Usr.UserKey,
	CAST(SYSDATETIME() AS DATE),
	'2099-12-31'
FROM
	sec.Users Usr
		INNER JOIN
	dim.Provider Prov
		ON Usr.UserName = Prov.ProviderName
		INNER JOIN
	dim.Department Dept
		ON Prov.ProviderSpecialty = Dept.Department
WHERE
	Usr.AllDepartmentsFlag = 'N';


--	Remove my security for the Cardiology department
UPDATE
	UsrDept
SET
	EndEffectiveDate = '2015-04-01'
FROM
	sec.UserDepartment UsrDept
		INNER JOIN
	sec.Users Usr
		ON UsrDept.UserKey = Usr.UserKey
		INNER JOIN
	dim.Department Dept
		ON UsrDept.DepartmentKey = Dept.DepartmentKey
WHERE
	Usr.UserName = 'Hyde, Chris'
	AND
	Dept.Department = 'Cardiology';

GO


CREATE VIEW vwUserDepartmentActive AS
SELECT
	DepartmentKey,
	UserKey
FROM
	MyHospital.sec.UserDepartment Dept
WHERE
	CAST(SYSDATETIME() AS DATE) BETWEEN Dept.StartEffectiveDate AND Dept.EndEffectiveDate;

GO


CREATE VIEW vwTabularPermissions AS
SELECT DISTINCT
	Dept.DepartmentKey,
	Usr.UserLogin
FROM
	MyHospital.sec.UserDepartment Dept
		INNER JOIN
	MyHospital.sec.Users Usr
		ON Dept.UserKey = Usr.UserKey
WHERE
	CAST(SYSDATETIME() AS DATE) BETWEEN Dept.StartEffectiveDate AND Dept.EndEffectiveDate;
