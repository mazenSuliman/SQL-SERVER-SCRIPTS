DECLARE
	 @MRN			INT				= 0
	,@DOCTOR		VARCHAR(21)		= '%'
	,@SPECIALITY	VARCHAR(21)		= '%'
	,@FROMDATE		SMALLDATETIME	= '2010-01-01'
	,@TODATE		SMALLDATETIME	= '2058-12-31'

SELECT  DISTINCT 
		 CONVERT(DATE, C.RegDate)				AS DATE_SL
		--,CONVERT(TIME, C.RegDate)				AS TIME_SL
		,D.Code									AS DOCTOR_CODE
		,C.menu_tb10							AS DOCTOR_NAME
		,DS.Code								AS SP_CODE
		,DS.ArbName								AS SP_NAME
		,P.ArbName								AS PATIENT_NAME
		,C.menu_tb4								AS MRN
		,C.menu_tb21							AS DIAGNOSIS
		,C.menu_tb17							AS SickLeaveDays
		
FROM CF_SL C
	JOIN Patients P				ON P.FileNum = C.menu_tb4
	JOIN Doctors  D				ON D.ArbName = C.menu_tb10
	JOIN DoctorsSpecialties DS	ON D.DoctorSpecialtyID = DS.ID

WHERE
	CONVERT(DATE, C.RegDate) BETWEEN @FROMDATE AND @TODATE
	AND C.menu_tb4	= IIF(@MRN = 0, C.menu_tb4, @MRN)
	AND DS.Code		= IIF(@SPECIALITY = '%', DS.Code, @SPECIALITY)