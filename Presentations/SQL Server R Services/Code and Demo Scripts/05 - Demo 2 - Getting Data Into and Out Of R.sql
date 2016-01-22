--	Set initial configuration, used for later in the script
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 0;
RECONFIGURE;



--	Query #1: We pass the top ten numbers from the tally table into R, and retrieve them straight back
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language		= N'R',
	@script			= N'OutputDataSet <- InputDataSet;',
	@input_data_1	= N'SELECT TOP 10 * FROM Admin.dbo.Tally;'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #2: The same query as #1, but with the input data name specified
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language			= N'R',
	@script				= N'OutputDataSet <- myQuery;',
	@input_data_1		= N'SELECT TOP 10 * FROM Admin.dbo.Tally;',
	@input_data_1_name	= N'myQuery'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #3: The same query as #1 and #2, but with both the input and output data names specified
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language			= N'R',
	@script				= N'Results <- myQuery;',
	@input_data_1		= N'SELECT TOP 10 * FROM Admin.dbo.Tally;',
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #4: The same query as #3, but using a variable for the input query
------------------------------------------------------------------------------------------------------
DECLARE @InputQuery		NVARCHAR(500);
SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= N'Results <- myQuery;',
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #5: The same query as #4, but using variables for both the input query and the R script
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @RScript = N'
Results <- myQuery;
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #6: Now we'll start manipulating the data.  First we'll get the standard deviation
--	of our data set.  (Note: this will fail!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @RScript = N'
Results <- sd(myQuery);
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #7: Let's try to get the standard deviation again using a vector instead
--	(Note: this will fail too!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @RScript = N'
Results <- sd(myQuery$SequenceNumber);
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #8: Now this way will work - remember, data frame in, data frame out!
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @RScript = N'
Results <- as.data.frame(sd(myQuery$SequenceNumber));
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------





--	Query #9: Let's look at a more interesting set of data.  Note we don't need an input query here!
--	(Note: this one will fail!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'';

SET @RScript = N'
Results <- iris;
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #10: Let's try #9 again, but with the result set specified correctly this time.
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@RScript		NVARCHAR(500);

SET @InputQuery = N'';

SET @RScript = N'
Results <- iris;
';

EXEC sp_execute_external_script
	@language			= N'R',
	@script				= @RScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	"SepalLength"	NUMERIC(4, 1) NOT NULL, 
	"SepalWidth"	NUMERIC(4, 1) NOT NULL,
	"PetalLength"	NUMERIC(4, 1) NOT NULL, 
	"PetalWidth"	NUMERIC(4, 1) NOT NULL,
	"Species"		VARCHAR(20)
));
------------------------------------------------------------------------------------------------------



--	Query #11: Let's use OPENROWSET to put this data into a table.  Note that this will fail if
--	we haven't enabled ad hoc distributed queries.
------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Iris')
	DROP TABLE Admin.dbo.Iris;


SELECT
	*
INTO
	Admin.dbo.Iris
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''R'',
			@script				= N''Results <- iris;'',
			@input_data_1		= N'''',
			@input_data_1_name	= N''myQuery'',
			@output_data_1_name	= N''Results''
		WITH RESULT SETS
		((
			"SepalLength"	DECIMAL(4, 1) NOT NULL, 
			"SepalWidth"	DECIMAL(4, 1) NOT NULL,
			"PetalLength"	DECIMAL(4, 1) NOT NULL, 
			"PetalWidth"	DECIMAL(4, 1) NOT NULL,
			"Species"		VARCHAR(20)
		));');
------------------------------------------------------------------------------------------------------



--	Query #12: Let's enable the ad hoc distributed queries and see the results.
------------------------------------------------------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;


IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Iris')
	DROP TABLE Admin.dbo.Iris;


SELECT
	*
INTO
	Admin.dbo.Iris
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''R'',
			@script				= N''Results <- iris;'',
			@input_data_1		= N'''',
			@input_data_1_name	= N''myQuery'',
			@output_data_1_name	= N''Results''
		WITH RESULT SETS
		((
			"SepalLength"	DECIMAL(4, 1) NOT NULL, 
			"SepalWidth"	DECIMAL(4, 1) NOT NULL,
			"PetalLength"	DECIMAL(4, 1) NOT NULL, 
			"PetalWidth"	DECIMAL(4, 1) NOT NULL,
			"Species"		VARCHAR(20)
		));');

SELECT
	*
FROM
	Admin.dbo.Iris;
------------------------------------------------------------------------------------------------------
