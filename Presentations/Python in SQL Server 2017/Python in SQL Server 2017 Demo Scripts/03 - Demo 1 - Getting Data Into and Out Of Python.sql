--	Set initial configuration, used for later in the script
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 0;
RECONFIGURE;


USE PyDemo;
GO


--	Query #1: Hello World.
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language		= N'Python',
	@script			= N'print("Welcome to SQL Saturday Atlanta 2017!")';
------------------------------------------------------------------------------------------------------



--	Query #2: We pass the top ten numbers from the tally table into Python, and
--	retrieve them straight back.
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language		= N'Python',
	@script			= N'OutputDataSet = InputDataSet',
	@input_data_1	= N'SELECT TOP 10 * FROM Admin.dbo.Tally;'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #3: The same query as #2, but with the input data name specified.
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= N'OutputDataSet = myQuery',
	@input_data_1		= N'SELECT TOP 10 * FROM Admin.dbo.Tally;',
	@input_data_1_name	= N'myQuery'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #4: The same query as #2 and #3, but with both the input and output data
--	names specified.
------------------------------------------------------------------------------------------------------
EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= N'Results = myQuery',
	@input_data_1		= N'SELECT TOP 10 * FROM Admin.dbo.Tally;',
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #5: The same query as #4, but using a variable for the input query.
------------------------------------------------------------------------------------------------------
DECLARE @InputQuery		NVARCHAR(500);
SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= N'Results = myQuery',
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #6: The same query as #5, but using variables for both the input
--	query and the Python script.
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @PyScript = N'
Results = myQuery
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 INT NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #7: Now we'll start manipulating the data.  First we'll get the standard
--	deviation of our data set.  (Note: this will fail!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @PyScript = N'
Results = std(myQuery)
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #8: Let's try to get the standard deviation again using the numpy
--	function std instead.  (Note: this will fail too!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @PyScript = N'
import numpy as np

Results = np.std(myQuery)
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #9: Now this way will work - remember, data frame in, data frame out!
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @PyScript = N'
import numpy as np
import pandas as pd

Results = pd.DataFrame(np.std(myQuery))
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #10: The same query in R.  Note the different result!
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



--	Query #11: Add the ddof argument (delta degrees of freedom) to return a sample
--	standard deviation instead of a population standard deviation.
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'
SELECT TOP 10
	SequenceNumber
FROM
	Admin.dbo.Tally;
';

SET @PyScript = N'
import numpy as np
import pandas as pd

Results = pd.DataFrame(np.std(myQuery, ddof = 1))
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #12: Let's look at a more interesting set of data.  Note we don't need
--	an input query here!  (Note: this one will fail!)
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'';

SET @PyScript = N'
import pandas as pd
from pydataset import data

iris = data("iris")

Results = pd.DataFrame(iris)
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
	@input_data_1		= @InputQuery,
	@input_data_1_name	= N'myQuery',
	@output_data_1_name	= N'Results'
WITH RESULT SETS
((
	[NewColumnName]	 NUMERIC(6, 4) NOT NULL
));
------------------------------------------------------------------------------------------------------



--	Query #13: Let's try #12 again, but with the result set specified correctly this time.
------------------------------------------------------------------------------------------------------
DECLARE
	@InputQuery		NVARCHAR(500),
	@PyScript		NVARCHAR(500);

SET @InputQuery = N'';

SET @PyScript = N'
import pandas as pd
from pydataset import data

iris = data("iris")

Results = pd.DataFrame(iris)
';

EXEC sp_execute_external_script
	@language			= N'Python',
	@script				= @PyScript,
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



--	Query #14: Let's use OPENROWSET to put this data into a table.  Note that this will fail if
--	we haven't enabled ad hoc distributed queries.
------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Iris')
	DROP TABLE dbo.Iris;


SELECT
	*
INTO
	dbo.Iris
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''Python'',
			@script				= N''import pandas as pd
from pydataset import data

iris = data("iris")

Results = pd.DataFrame(iris)'',
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



--	Query #15: Let's enable the ad hoc distributed queries and see the results.
--	Unfortunately, this one will fail due to formatting.  Python is picky!
------------------------------------------------------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;


IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Iris')
	DROP TABLE dbo.Iris;


SELECT
	*
INTO
	dbo.Iris
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''Python'',
			@script				= N''import pandas as pd
									from pydataset import data

									iris = data("iris")

									Results = pd.DataFrame(iris)'',
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
	dbo.Iris;
------------------------------------------------------------------------------------------------------



--	Query #16: Now that we've fixed the formatting, everything will run nicely!
------------------------------------------------------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;


IF EXISTS(SELECT * FROM sys.tables WHERE name = 'Iris')
	DROP TABLE dbo.Iris;


SELECT
	*
INTO
	dbo.Iris
FROM
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;', N'
		EXEC sp_execute_external_script
			@language			= N''Python'',
			@script				= N''import pandas as pd
from pydataset import data

iris = data("iris")

Results = pd.DataFrame(iris)'',
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
	dbo.Iris;
------------------------------------------------------------------------------------------------------
