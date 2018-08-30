DECLARE
	 @FROMDATE		SMALLDATETIME		= '2018-01-01'
	,@TODATE		SMALLDATETIME		= '2018-01-01'
	,@DOCTOR		VARCHAR(15)			= '%'
	,@SPECIALTY		VARCHAR(25)			= '%'
	,@SERVICEITEM	VARCHAR(25)			= '%'
	,@SERVICEGROUP	VARCHAR(25)			= '%'
	,@TOP			INT					= 10

BEGIN
WITH DOCTOR_ITEM
AS(
	SELECT	DISTINCT	 
		 Do.Code																AS DOCTOR_CODE
		,MAX(Do.EngName)														AS DOCTOR_NAME
		,MAX(Ds.EngName)														AS SPECALITY
		,MAX(H.PatientFileNum)													AS FILE_NUM
		,I.Code																	AS ITEM_CODE
		,MAX(I.EngName)															AS ITEM_NAME
		,COUNT(I.Code)															AS REQEST_TIMES
		,ROW_NUMBER() OVER (PARTITION BY Do.CODE ORDER BY COUNT(I.Code) DESC)	AS ROWNUMBER
		,@FROMDATE																AS FROMDATE
		,@TODATE																AS TODATE

	FROM   
		TransHdr						H 
		JOIN TransDtl					D		ON D.TransHdrID					= H.ID
		JOIN Doctors					Do		ON H.DoctorID					= Do.ID
		JOIN DoctorsSpecialties			Ds		ON Do.DoctorSpecialtyID			= Ds.ID
		JOIN ServiceItems				I		ON D.ServiceItemID				= I.ID
		JOIN ServiceGroups				G		ON I.ServiceGroupID				= G.ID
		
	WHERE 
		H.CancelDate IS NULL
		AND I.CancelDate is null		
		AND H.TransDate BETWEEN @FROMDATE AND @TODATE
		AND Do.Code LIKE @DOCTOR	+ '%'
		AND Ds.Code LIKE @SPECIALTY + '%'
		AND I.Code = IIF(@SERVICEITEM = '%', I.Code, @SERVICEITEM)
		AND G.Code = IIF(@SERVICEGROUP = '%', G.Code, @SERVICEGROUP)

	GROUP BY 
		 Do.Code
		,I.Code
		)
		
SELECT * 
FROM DOCTOR_ITEM DD
WHERE DD.ROWNUMBER <= IIF(@TOP <= 0 OR @TOP > 10, 5, @TOP)
ORDER BY DOCTOR_CODE, ROWNUMBER
END