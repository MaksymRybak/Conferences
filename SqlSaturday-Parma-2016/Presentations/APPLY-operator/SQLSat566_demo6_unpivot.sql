--SQL Saturday 566. Parma 26 november 2016. 
--6. UNPIVOTING

USE Test;
GO

/*
--Create table for registering course attendance
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('dbo.Attendance') AND type = 'U')
DROP TABLE dbo.Attendance;

CREATE TABLE [dbo].[Attendance](
	[idTable] [int] IDENTITY(1,1) NOT NULL,
	[SessionId] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL,
	[WeekOfYear] int NULL,
	[SessionStartDate] [date] NULL,
	[SessionEndDate] [date] NULL,
	[Day1] [nvarchar](20) NULL,
	[Day2] [nvarchar](20) NULL,
	[Day3] [nvarchar](20) NULL,
	[Day4] [nvarchar](20) NULL,
	[Day5] [nvarchar](20) NULL,

	PRIMARY KEY CLUSTERED 
	([idTable] ASC)
);
GO
CREATE NONCLUSTERED INDEX idx_SessId ON dbo.Attendance(SessionId) INCLUDE(UserName)
*/

SELECT SessionId, UserName, WeekOfYear, SessionStartDate, SessionEndDate, Day1, Day2, Day3, Day4, Day5
FROM dbo.Attendance;

--every attendee can have more than one row on the same session
SELECT SessionId, UserName, Day1, Day2, Day3, Day4, Day5, WeekOfYear
FROM dbo.Attendance
WHERE SessionId = '357631C7-5190-4D00-920A-113DF4892008' AND UserName = '2080'

--Attendance is registered on a weekly basic. Day1 as Monday, Day2 as Tuesday etc. Every day of attendance is registered
--as 'Attendant'. We want to calculate for every employee, the total attendance hours. 
--Every attendant is counted as 1 day. 1 day lasts 8 hours.
--We use a function to unpivot the table and then sum the hours for every employee. 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_CalculateAttendance') AND type = 'IF')
DROP FUNCTION dbo.ufn_CalculateAttendance;
GO

CREATE FUNCTION [dbo].[ufn_CalculateAttendance] (@user_id nvarchar(20), @sess_id nvarchar(50))
--cte to unpivot table. Retrieves SessionID e Username
RETURNS TABLE	
AS 
RETURN 
WITH unpvt AS (
	SELECT 
		SessionId, 
		UserName, 
		CalcAttendance, 
		CASE WHEN CalcAttendance = 'Attended' THEN 1 ELSE 0 END AS AttDay
	FROM (
		SELECT SessionId, UserName, Day1, Day2, Day3, Day4, Day5
		FROM dbo.Attendance
		WHERE SessionId = @sess_id AND UserName = @user_id) p
	UNPIVOT(CalcAttendance FOR WeekOfYear IN(Day1, Day2, Day3, Day4, Day5)
	) AS up
) 
SELECT SessionId, UserName, Sum(AttDay) AS TotAttDays 
FROM unpvt
GROUP BY SessionId, UserName
;

GO


SELECT * FROM dbo.ufn_CalculateAttendance('2080', '357631C7-5190-4D00-920A-113DF4892008');

--Test the function
SELECT 
	a.UserName, 
	a.SessionId,
	ca.TotAttDays
FROM dbo.Attendance a
	CROSS APPLY dbo.ufn_CalculateAttendance(a.UserName,a.SessionId) ca
;


---------------------------------------------------------------------------------------------------------------------------------
--Example of a table value constructor
SELECT CodiceProvincia, Provincia, Regione
FROM (VALUES
	('BL','Belluno','Veneto'),
	('PD','Padova','Veneto'),
	('RO','Rovigo','Veneto'),
	('CA','Cagliari','Sardegna'),
	('OR','Oristano','Sardegna'),
	('SS','Sassari','Sardegna')
	) AS v(CodiceProvincia, Provincia, Regione)


--Unpivoting the table using a table value constructor
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ufn_CalculateAttendance_vls') AND type = 'IF')
DROP FUNCTION dbo.ufn_CalculateAttendance_vls;
GO

CREATE FUNCTION [dbo].[ufn_CalculateAttendance_vls] (@user_id nvarchar(20), @sess_id nvarchar(50))
--cte to unpivot table. Retrieves SessionID e Username
RETURNS TABLE	
AS 
RETURN 
WITH vls AS (
	SELECT 
		SessionId, 
		UserName, 
		xvalues.NrDay, 
		xvalues.ValDay,
		CASE WHEN ValDay = 'Attended' THEN 1 ELSE 0 END AS AttDay
	FROM dbo.Attendance
		CROSS APPLY (
			VALUES('Day1',Day1),('Day2',Day2),('Day3',Day3),('Day4',Day4),('Day5',Day5)
			) xvalues (NrDay,ValDay)
	WHERE SessionId = @sess_id AND UserName = @user_id
)
SELECT 
	SessionId, UserName, Sum(AttDay) AS TotAttDays 
FROM vls
GROUP BY SessionId, UserName
;
GO

--Test the function
 SELECT 
	a.UserName, 
	a.SessionId,
	ca.TotAttDays
FROM dbo.Attendance a
	CROSS APPLY dbo.ufn_CalculateAttendance_vls(a.UserName,a.SessionId) ca