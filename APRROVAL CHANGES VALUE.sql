DECLARE
	 @SERVICEITEM	VARCHAR(20)		= '025000004'
	,@MRN			INTEGER			= 0
	,@DOCTOR		VARCHAR(20)		= '10541'
	,@FROMDATE		SMALLDATETIME	= '2018-01-01'
	,@TODATE		SMALLDATETIME	= '2018-12-31'

SELECT	  P.FileNum
		, P.EngName
		, C.RegDate
		, DO.Code
		, DO.EngName
		, D.ServiceItemCode
		, I.EngName
		, U.Code
		, U.EngName
		, D.RegDate

FROM     ApprovalDtl	D
	JOIN ApprovalHdr	H  ON D.ApprovalHdrID	= H.ID
	JOIN ChangeHistory	C  ON C.RecordID		= D.ID
	JOIN PATIENTS		P  ON H.PatientID		= P.ID
	JOIN SystemUsers	U  ON C.RegUserID		= U.ID
	JOIN ServiceItems	I  ON D.ServiceItemID	= I.ID
	JOIN Doctors		DO ON D.DoctorID		= DO.ID

WHERE H.PatientFileNum =IIF(@MRN = 0, H.PatientFileNum, @MRN)
	AND D.ServiceItemCode = IIF(@SERVICEITEM = '%', D.ServiceItemCode, @SERVICEITEM)
	AND C.TableName = 'ApprovalDtl'
	AND C.FIELD LIKE 'ApprovalDate'
	AND C.RegDate BETWEEN @FROMDATE AND @TODATE