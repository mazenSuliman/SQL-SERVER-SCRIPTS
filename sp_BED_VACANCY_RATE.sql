USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_BED_VACANCY_RATE]    Script Date: 02/08/2018 11:20:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_BED_VACANCY_RATE] 
	@FROMDATE	SMALLDATETIME = '2017-12-13'
	
AS
BEGIN
	SELECT	  P.FileNum									AS MRN
			, P.EngName									AS PATIENT_NAME
			, CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, 1, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1)-1)) ELSE B.Code END										  AS WARD
			,COUNTY.COU
			, CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1) + 1), LEN(B.CODE)) ELSE B.Code END AS BED_CODE
			, FORMAT(AdmDate, 'dd-MMM-yyyy')			AS ADMISSION_DATE
			, AdmTime									AS ADMISSION_TIME
			, FORMAT(DsgDate, 'dd-MMM-yyyy')			AS DISCHARGE_DATE
			, CASE WHEN DsgTime = '' AND DsgDate IS NOT NULL THEN '00:00' WHEN DsgDate IS  NULL THEN 'NOT DISCHARG YET' ELSE DsgTime END	AS DISCHARGE_TIME
			, CASE 
				WHEN (AdmDate < DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) AND A.DsgDate <  DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0)) OR AdmDate > EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0)) THEN 0
				WHEN AdmDate > DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) AND A.DsgDate < EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) )THEN DATEDIFF(DAY, A.AdmDate, A.DsgDate)
				WHEN AdmDate < DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) AND A.DsgDate < EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) )THEN DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0), A.DsgDate)
				WHEN AdmDate > DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) AND (A.DsgDate > EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) ) OR A.DsgDate IS NULL)THEN DATEDIFF(DAY, AdmDate,  EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) ))+1
				WHEN AdmDate < DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) AND (A.DsgDate > EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) ) OR A.DsgDate IS NULL)THEN DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0) ,  EOMONTH(DATEADD(month, DATEDIFF(month, 0, @FROMDATE), 0)))+1
				END D
			,@FROMDATE FROMDATE
			,CONVERT(INT, FORMAT(EOMONTH(@FROMDATE), 'dd'))  ENDMONTH
			,TOTALBEDS = (SELECT COUNT(*) FROM Beds)


	FROM Admissions A
			INNER JOIN Patients P		ON A.PatientID	= P.ID
			INNER JOIN Beds B			ON A.BedID		= B.ID
			INNER JOIN BedsClasses BC	ON A.BedClassID = BC.ID
			INNER JOIN (SELECT CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, 1, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1)-1)) ELSE B.Code END										  AS WARD, COUNT(*) COU
						FROM Beds B
						GROUP BY CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, 1, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1)-1)) ELSE B.Code END) AS COUNTY ON COUNTY.WARD = CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, 1, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1)-1)) ELSE B.Code END

	WHERE A.CancelDate IS NULL
END
