SET DATEFORMAT DMY
DECLARE
	@MRN            int = 552844,
	@FROMDATE		SMALLDATETIME = '13/01/2018',
	@TODATE			SMALLDATETIME = '13/01/2018'

SELECT    ANTIBIOTICS.TDID						AS ID
		, ANTIBIOTICS.SpecimenNumber			AS SPECIMEN#
		, H.PatientFileNum						AS MRN
		, P.EngName								AS P_NAME
		, P.Sex									AS SEX
		, YEAR(H.TRANSDATE) - YEAR(P.DOB)		AS AGE
		, IIF(H.InOut = 'I', B.Code, 'OPD')		AS LOCATIONS
		, H.RegDate								AS DATE_TIME
		, BODIES.ORGANISMORDER					AS ORG_NUMBER
		, BODIES.Data							AS ORG_NAME
		, SPECIMEN.Data							AS SPECIMEN
		, ANTIBIOTICS.Caption					AS ANTIBIOTIC_NAME
		, ANTIBIOTICS.Data						AS RESULT


FROM TransHdr			H		WITH (NOLOCK)
	JOIN TransDtl		D		WITH (NOLOCK) ON D.TransHdrID	= H.ID
	JOIN Patients		P		WITH (NOLOCK) ON H.PatientID	= P.ID
	JOIN Admissions		A		WITH (NOLOCK) ON H.AdmissionID	= A.ID
	JOIN Beds			B		WITH (NOLOCK) ON A.BedID		= B.ID

	JOIN (SELECT  SUBSTRING(LFCG.Caption, 19, 10) AS ORGANISMORDER, LFC.Caption, TDLFD.Data, LFCG.Rank, D.ID, TDLFD.ID AS TDID, TDCFS.SpecimenNumber
			FROM TransHdr H
				JOIN TransDtl D ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens TDCFS ON TDCFS.TransDtlsID = D.ID And RTRIM(TDCFS.SpecimenStatus) <> 'REJ' And RTRIM(TDCFS.SpecimenStatus) <> 'CAN'
				JOIN TransDtlLabFormsData TDLFD ON TDLFD.TransDtlCustomFormSpecimenID = TDCFS.ID
				JOIN LabFormControls LFC ON TDLFD.LabFormControlID = LFC.ID
				LEFT JOIN LabFormControlsGroups LFCG ON LFC.LabFormControlsGroupID = LFCG.ID
				LEFT JOIN LabForms LF ON LFCG.LabFormID = LF.ID
			WHERE H.CancelDate IS NULL
				AND  H.PatientFileNum = IIF(@MRN = 0,  H.PatientFileNum, @MRN)
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE
				AND LFCG.Caption LIKE '%SENSITIVITY TEST (ORGANISM%'
				AND (TDLFD.Data IS NOT NULL AND TDLFD.Data NOT LIKE '')	
				AND TDLFD.CancelDate IS NULL 
				AND TDLFD.Data IS NOT NULL 
				AND TDLFD.Data <> '') AS ANTIBIOTICS ON ANTIBIOTICS.ID = D.ID

	JOIN (SELECT  SUBSTRING(LFCG.Caption, 10, 10) AS ORGANISMORDER, TDLFD.Data, D.ID
			FROM TransHdr H
				JOIN TransDtl D ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens TDCFS ON TDCFS.TransDtlsID = D.ID
				JOIN TransDtlLabFormsData TDLFD ON TDLFD.TransDtlCustomFormSpecimenID = TDCFS.ID
				JOIN LabFormControls LFC ON TDLFD.LabFormControlID = LFC.ID
				JOIN LabFormControlsGroups LFCG ON LFC.LabFormControlsGroupID = LFCG.ID
				JOIN LabForms LF ON LFCG.LabFormID = LF.ID
			WHERE H.PatientFileNum = IIF(@MRN = 0,  H.PatientFileNum, @MRN)
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE
				AND LFCG.Caption LIKE '%CULTURE (ORGANISM%'	
				AND TDLFD.CancelDate IS NULL 
				AND TDLFD.Data IS NOT NULL 
				AND TDLFD.Data <> '') AS BODIES ON BODIES.ID = D.ID AND ANTIBIOTICS.ORGANISMORDER = BODIES.ORGANISMORDER

	JOIN (SELECT DISTINCT TDLFD.Data, D.ID
			FROM TransHdr H
				JOIN TransDtl D ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens TDCFS ON TDCFS.TransDtlsID = D.ID
				JOIN TransDtlLabFormsData TDLFD ON TDLFD.TransDtlCustomFormSpecimenID = TDCFS.ID
				JOIN LabFormControls LFC ON TDLFD.LabFormControlID = LFC.ID
				JOIN LabFormControlsGroups LFCG ON LFC.LabFormControlsGroupID = LFCG.ID
			WHERE H.PatientFileNum = IIF(@MRN = 0,  H.PatientFileNum, @MRN)
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE
				AND LFCG.Caption LIKE '%SPECIMEN TYPE%') AS SPECIMEN ON SPECIMEN.ID = D.ID

WHERE H.CancelDate IS NULL
	AND H.PatientFileNum = IIF(@MRN = 0,  H.PatientFileNum, @MRN)
	AND H.TransDate BETWEEN @FROMDATE AND @TODATE

ORDER BY H.RegDate, H.PatientFileNum, BODIES.ORGANISMORDER, BODIES.Data, ANTIBIOTICS.Caption