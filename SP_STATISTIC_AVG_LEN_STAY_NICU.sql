USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_STATISTIC_AVG_LEN_STAY_NICU]    Script Date: 02/08/2018 11:35:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_STATISTIC_AVG_LEN_STAY_NICU] 
	 @MRN		VARCHAR(50) = '%'
	,@FROMDATE	SMALLDATETIME = '2007-01-01'
	,@TODATE    SMALLDATETIME = '2047-12-31'

AS
BEGIN
	SELECT	  P.FileNum									AS MRN
			, P.EngName									AS PATIENT_NAME
			, CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, 1, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1)-1)) ELSE B.Code END										  AS WARD
			, CASE WHEN CHARINDEX('-', B.Code) > 0 THEN SUBSTRING(B.Code, (CHARINDEX('-', B.Code, CHARINDEX('-', B.Code) + 1) + 1), LEN(B.CODE)) ELSE B.Code END AS BED_CODE
			, FORMAT(AdmDate, 'dd-MMM-yyyy')			AS ADMISSION_DATE
			, AdmTime									AS ADMISSION_TIME
			, FORMAT(DsgDate, 'dd-MMM-yyyy')			AS DISCHARGE_DATE
			, CASE WHEN DsgTime = '' THEN '00:00' ELSE DsgTime END	AS DISCHARGE_TIME
			, DATEDIFF(DAY, AdmDate, DsgDate)			AS STAY_LENGTH
			, @FROMDATE									AS FROMDATE
			, @TODATE									AS TODATE

	FROM Admissions A
			INNER JOIN Patients P		ON A.PatientID	= P.ID
			INNER JOIN Beds B			ON A.BedID		= B.ID
			INNER JOIN BedsClasses BC	ON A.BedClassID = BC.ID

	WHERE A.DsgDate BETWEEN @FROMDATE AND @TODATE
			AND A.DsgDate IS NOT NULL
			AND P.FileNum LIKE @MRN + '%'
			AND DATEDIFF(DAY, AdmDate, DsgDate)	> 0
			AND B.Code LIKE '%NICU%'
END