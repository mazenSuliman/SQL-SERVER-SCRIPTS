DECLARE
		 @FILENUM	INT				= 0
		,@INOUT		VARCHAR(4)			= 'OUT'
		,@NATIONALITY VARCHAR(45)		= '%'
		,@FROMDATE	SMALLDATETIME	= '2018-02-01'
		,@TODATE	SMALLDATETIME	= '2018-02-28'

SELECT DISTINCT
        P.FileNum											AS MRN
       ,P.EngName											AS P_NAME
       ,N.EngName											AS NATIONALITY
	   ,IIF(H.InOut = 'I', 'IN', 'OUT')						AS LOCATION
       ,IIF(PP.ID IS NULL, 'NOT PREGNANT', 'PREGNANT')		AS PREGNANCY_STATUS
       ,H.TransDate											AS TransDate
	   ,SD.DATA												AS RESULT
        
FROM 
       TransDtl										D
       JOIN TransHdr								H		ON D.TransHdrID						= H.ID
       --JOIN TransHdrIM HIM								ON D.TransDtlIMID					= HIM.ID
       JOIN Patients								P		ON H.PatientID						= P.ID
       JOIN Nationalities							N		ON P.NationalityID					= N.ID
       LEFT JOIN PatientsPregnancy					PP		ON PP.PatientID						= P.ID
	    JOIN TransDtlCustomFormsSpecimens		SP		ON SP.TransDtlsID					= D.ID
		Inner JOIN dbo.TransDtlLabFormsData			SD		ON SD.TransDtlCustomFormSpecimenID	=  SP.ID 

WHERE 
       H.CancelDate					 IS NULL
       AND P.Sex					 = 'F'
	   AND D.ServiceItemCode		 = '026000383'
	   AND RTRIM(SP.SpecimenStatus) <> 'REJ' 
	   AND RTRIM(SP.SpecimenStatus) <> 'CAN'
	   AND H.IsConsultation = 0
	   AND SD.Data <> ''
	   AND P.FILENUM = IIF(@FILENUM = 0, P.FILENUM, @FILENUM)
		AND N.Code = IIF(@NATIONALITY = '%', N.CODE, @NATIONALITY)
		AND H.InOut = CASE WHEN @INOUT = 'IN' THEN 'I' WHEN @INOUT = 'OUT' THEN 'O' ELSE H.InOut END
	   AND H.TransDate BETWEEN @FROMDATE AND @TODATE

ORDER BY 
		TransDate, MRN
	   