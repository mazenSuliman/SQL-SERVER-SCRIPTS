DECLARE
	 @FROMDATE	SMALLDATETIME	= '2018-06-01'
	,@TODATE	SMALLDATETIME	= '2018-06-30'
	,@DOCTOR	VARCHAR(15)		= '%'
	,@SPECIALTY	VARCHAR(25)		= '%'
	,@TOP		INT				= 100
	;

WITH DOCTOR_DIAG
AS(
	SELECT	DISTINCT	 
		 Do.Code																AS DOCTOR_CODE
		,MAX(Do.EngName)														AS DOCTOR_NAME
		,MAX(Ds.EngName)														AS SPECALITY
		,ICD.Code																AS DIAG_CODE
		,MAX(ICD.Description)													AS DAIG_NAME
		,COUNT(ICD.Code)														AS REQEST_TIMES
		,ROW_NUMBER() OVER (PARTITION BY Do.CODE ORDER BY COUNT(ICD.Code) DESC) AS ROWNUMBER
		,@FROMDATE																AS FROMDATE
		,@TODATE																AS TODATE

	FROM   
		TransHdr						H 
		JOIN TransDtl					D		ON D.TransHdrID					= H.ID
		JOIN Doctors					Do		ON H.DoctorID					= Do.ID
		JOIN DoctorsSpecialties			Ds		ON Do.DoctorSpecialtyID			= Ds.ID
		JOIN TransDtlMedicalData		TM		ON D.ID							= TM.TransDtlID
		JOIN TransDtlMedicalDataDtls	TMD		ON TMD.TransDtlMedicalDataID	= TM.id
		JOIN MedicalDataTypes			MT1		ON TMD.MedicalDataTypeID		= MT1.id
		JOIN ICDs						ICD		ON ICD.ID						= TMD.ICDID

		
	WHERE 
		H.CancelDate IS NULL
		AND TMD.CancelDate is null
		AND MT1.Code = 'DIAG'
		
		AND H.TransDate BETWEEN @FROMDATE AND @TODATE
		AND Do.Code LIKE @DOCTOR	+ '%'
		AND Ds.Code LIKE @SPECIALTY + '%'

	GROUP BY 
		 Do.Code
		,ICD.Code
		)

SELECT * FROM DOCTOR_DIAG
WHERE ROWNUMBER <= CASE WHEN @TOP <= 0 THEN 5 WHEN @TOP >= 15 THEN 15 ELSE @TOP END --IIF(@TOP <= 0, 5, @TOP)
ORDER BY DOCTOR_CODE, ROWNUMBER