##	Open a connection to the SQL Server
library(RODBC);
conn <- odbcDriverConnect("Driver=SQL Server; Server=(local); Database=RDemo; Uid=RDemo; Pwd=RDemo;");


##	Define the query used to retrieve data
queryDef <- "
SELECT
	MeasuredDate,
	TotalSizeInMB = SUM(DatabaseSizeInMB)
FROM
	dbo.tblDatabaseSize
GROUP BY
	MeasuredDate
ORDER BY
	MeasuredDate";


##	Load the query results into a data frame and close the connection
dfTotalSize <- sqlQuery(conn, queryDef);
odbcClose(conn);


##	Convert the measured date into a date datatype, and create vectors from the columns
MeasuredDate <- as.Date(dfTotalSize$MeasuredDate, "%Y-%m-%d");
TotalSizeInMB <- dfTotalSize$TotalSizeInMB;


##	Plot the database growth over time
xrange <- range(MeasuredDate);
yrange <- c(0, 100 * (floor(max(TotalSizeInMB) / 102400) + 1));

plot(xrange, yrange, type = "n", main = "Database Growth Over Time", xlab = "", ylab = "Total Size in GB");
lines(MeasuredDate, TotalSizeInMB / 1024, col = "blue", lwd = 2);


##	Perform linear regression and add line to chart
model <- lm(formula = (TotalSizeInMB / 1024) ~ MeasuredDate);
abline(model, col = "red", lwd = 2);


##	Calculate when the drive will be full!
driveSpaceInMB <- 1024 * 1024;
inverseModel <- lm(formula = MeasuredDate ~ TotalSizeInMB);
as.Date(predict(inverseModel, data.frame(TotalSizeInMB = driveSpaceInMB)), origin = "1970-01-01");
