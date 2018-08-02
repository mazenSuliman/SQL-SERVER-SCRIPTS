DECLARE
	 @ACCOUNT	VARCHAR(50)		= '16102001'
	,@MAINACCOUNT VARCHAR(50)	= '%'
	,@MRN		INT				= 0
	,@DOCTOR	VARCHAR(15)		= '%'
	,@SPECIALITY VARCHAR(15)	= '%'
	,@NATIONALITY VARCHAR(15)	= '%'
	,@INOUT		VARCHAR(15)		= '%'
	,@FROMDATE	SMALLDATETIME	= '2018-03-01'
	,@TODATE	SMALLDATETIME	= '2018-03-25'

BEGIN
SELECT	CASE WHEN H.InOut = 'O' THEN 'خارجي' WHEN H.InOut = 'I' THEN 'داخلي' END AS  InOut
		, AM.ARBNAME MAIN_NAME
		, A.Code ACCOUNT_CODE
		, A.ARBNAME ACCOUNT_NAME
		, P.FileNum
		,MAX(P.ArbName) P_NAME
		,MAX(YEAR(TRANSDATE) - YEAR(DOB)) AGE
		,MAX(IIF(P.Sex = 'F', 'أنثى', 'ذكر')) GENDER
		,MAX(P.Telephones) TELEPHONE
		,MAX(N.ARBNAME) NATION
		,MAX(DO.ArbName) D_NAME
		,MAX(DS.ARBNAME) SPECIALITY
		--, MAX(H.TransNum)
		, MAX(U.Code) USERID
		, MAX(U.ARBNAME) USERNAME
		--,(SELECT TransNum FROM TransHdr WHERE ID = H.ConsultationTransHdrID) CONSULTATION
		,SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2) + ROUND(ISNULL(D.PatientVat, 0), 2)) AS CNET
		,@FROMDATE FROMDATE
		,@TODATE TODATE
		
FROM     TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN DoctorsSpecialties DS ON DO.DoctorSpecialtyID = DS.ID
	JOIN PatientsClasses PC ON P.ClassID = PC.ID
	JOIN Nationalities N ON P.NationalityID = N.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN SystemUsers U ON H.RegUserID = U.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND A.CODE = CASE WHEN @ACCOUNT = '%' THEN A.CODE ELSE @ACCOUNT END
	AND AM.CODE = CASE WHEN @MAINACCOUNT = '%' THEN AM.CODE ELSE @MAINACCOUNT END
	AND P.FileNum = IIF(@MRN = 0, P.FileNum, @MRN)
	AND DO.Code = IIF(@DOCTOR = '%', DO.Code, @DOCTOR)
	AND DS.Code = IIF(@SPECIALITY = '%', DS.Code, @SPECIALITY)
	AND N.Code = IIF(@NATIONALITY = '%', N.Code, @NATIONALITY)
	AND H.InOut = CASE WHEN @INOUT = '%' THEN H.InOut WHEN @INOUT = 'OUT' THEN 'O' ELSE 'I' END
GROUP BY AM.ARBNAME, H.InOut,A.Code, A.ARBNAME, P.FileNum, H.ConsultationTransHdrID
ORDER BY H.InOut,A.Code, A.ARBNAME, P.FileNum
END
