DECLARE
	 @FROMDATE	SMALLDATETIME	= '2016-04-01'
	,@TODATE	SMALLDATETIME	= '2019-04-01'
	,@MRN		INT				= 0
	,@DOCTOR	VARCHAR(15)		= '%'
	,@SPECIALTY	VARCHAR(25)		= '%'

	SELECT 
		 P.FileNum
		,P.EngName														AS PATIENT_NAME	
		,N.EngName														AS NATIONALITY
		,YEAR(H.RegDate) - YEAR(P.DOB)									AS AGE
		,IIF(P.Sex = 'F', 'Female', 'Male')								AS GENDER
		,AC.Code														AS ACCOUNT_CODE
		,AC.EngName														AS ACCOUNT_NAME
		,Do.Code														AS DOCTOR_CODE
		,Do.EngName														AS DOCTOR_NAME
		,Ds.EngName														AS SPECALITY
		,H.TransNum
		,H.TransDate
		,ICD.Code														AS DIAG_CODE
		,ICD.Description												AS DAIG_NAME
		,IIF(A.ID IS NULL, 'NO', 'YES')									AS ADM_STATUS
		,A.AdmDate														AS ADMISSION_DATE
		,A.DsgDate														AS DISCHARGE_DATE
		,@FROMDATE														AS FROMDATE
		,@TODATE														AS TODATE

	FROM   
		TransHdr						H 
		JOIN TransDtl					D		ON D.TransHdrID					= H.ID
		LEFT JOIN Admissions			A		ON H.AdmissionID				= A.ID
		JOIN Accounts					AC		ON H.AccountID					= AC.ID
		JOIN Doctors					Do		ON H.DoctorID					= Do.ID
		JOIN DoctorsSpecialties			Ds		ON Do.DoctorSpecialtyID			= Ds.ID
		JOIN PATIENTS					P		ON H.PatientID					= P.ID
		JOIN Nationalities				N		ON P.NationalityID				= N.ID
		JOIN TransDtlMedicalData		TM		ON D.ID							= TM.TransDtlID
		JOIN TransDtlMedicalDataDtls	TMD		ON TMD.TransDtlMedicalDataID	= TM.id
		JOIN MedicalDataTypes			MT1		ON TMD.MedicalDataTypeID		= MT1.id
		JOIN ICDs						ICD		ON ICD.ID						= TMD.ICDID

	WHERE 
		H.CancelDate IS NULL
		AND TMD.CancelDate IS NULL
		AND MT1.Code = 'DIAG'		
		AND H.TransDate BETWEEN @FROMDATE AND @TODATE
		AND H.PatientFileNum = IIF(@MRN = 0, H.PatientFileNum, @MRN)
		AND Do.Code LIKE @DOCTOR	+ '%'
		AND Ds.Code LIKE @SPECIALTY + '%'
	
	ORDER BY 
		 H.TransDate
		,P.EngName
