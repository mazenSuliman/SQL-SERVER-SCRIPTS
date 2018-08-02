DECLARE
	  @MAINACCOUNT VARCHAR(50) = '65'
	,@FROMDATE	SMALLDATETIME = '2017-10-01'
	,@TODATE	SMALLDATETIME = '2017-10-31'


BEGIN
SELECT DISTINCT FileNum, PatientName, NAT, AccountName, MainAccount, DOCCODE, MIN(FIRSTDATE) FIRSTDATE, MAX(FIRSTDATE) LASTDATE, MIN(TransNum), PayMethod, SUM(GROSS) GROSS, SUM(DISCOUNT) DISCOUNT, SUM(DeductAmount) DEDUCT, SUM(PVAT) PVAT, SUM(NET) NET, SUM(CVAT) CVAT, SUM(CNET) CNET
FROM
(SELECT	 MAX(P.FileNum) FileNum
		,MAX(P.EngName) PatientName
		--,MAX(P.OutSideRecNum) PolicyNum
		,MAX(CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END) AS NAT
		,MAX(A.EngName) AccountName
		,MAX(H.TransDate) FIRSTDATE
		,MAX(H.TransNum) TransNum
		,MAX(CASE WHEN H.InOut = 'I' THEN 'IN' ELSE 'OUT' END)  LOCAT
		,MAX(CASE WHEN H.PayMethod = 'C' THEN 'CASH' ELSE 'CREDIT' END) PayMethod
		--,MAX(PC.EngName) PatClass
		,MAX(AM.EngName) MainAccount
		,MAX(DO.Code) DOCCODE
		--,MAX(H.TransDate) TransDate
		--,MAX(RS.EngName) ResCenter
		--,MAX(A.Code) AccountCode
		--,MAX(CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END) CODE
		--,MAX(CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END) EngName
		,SUM(D.Quantity) Quantity
		,SUM(ISNULL(D.SellingPrice, 0)) AS UNITPRICE
		,SUM(ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2))  AS GROSS
		,SUM(ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2))  AS DISCOUNT
		,SUM(ROUND(ISNULL(D.DeductAmount, 0), 2))  AS DeductAmount
		,SUM(ROUND(ISNULL(D.PatientVat, 0), 2))  AS PVAT
		,SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)))  AS NET
		,SUM(ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CVAT
		, SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CNET
		--,@FROMDATE FROMDATE
		--,@TODATE  TODATE
		
FROM TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON H.PatientClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN Nationalities N ON P.NationalityID = N.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID
	LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.ServiceItemID = I.ID AND AMID.AccountMainID = AM.ID
	--JOIN (SELECT H1.ID, MIN(H.TransNum) TransNum, MIN(H.TransDate) FROMDATE, MAX(H.TransDate) TODATE
	--		FROM TransHdr H
	--			JOIN TransHdr H1 ON H.ConsultationTransHdrID = H1.ID
	--		WHERE
	--			H.CancelDate IS NULL
	--			AND H.TransDate BETWEEN @FROMDATE AND @TODATE
	--		GROUP BY H1.ID, H1.TransNum
	--			) AS RELAT ON H.ConsultationTransHdrID = RELAT.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND H.InOut = 'O'
	AND AM.Code = CASE WHEN @MAINACCOUNT = '' THEN AM.Code ELSE @MAINACCOUNT END
	AND I.ServiceGroupID = 87
	--AND D.Quantity > 0

GROUP BY H.PatientFileNum, H.DoctorCode, H.TransDate, I.ServiceGroupID, D.ServiceItemCode
HAVING SUM(D.Quantity) > 0

UNION ALL

SELECT	 (P.FileNum) FileNum
		,(P.EngName) PatientName
		--,(P.OutSideRecNum) PolicyNum
		,(CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END) AS NAT
		,(A.EngName) AccountName
		,(H.TransDate) FIRSTDATE
		,(H.TransNum) TransNum
		,(CASE WHEN H.InOut = 'I' THEN 'IN' ELSE 'OUT' END)  LOCAT
		,(CASE WHEN H.PayMethod = 'C' THEN 'CASH' ELSE 'CREDIT' END) PayMethod
		--,(PC.EngName) PatClass
		,(AM.EngName) MainAccount
		,DO.Code DOCCODE
		--,(H.TransDate) TransDate
		--,(RS.EngName) ResCenter
		--,(A.Code) AccountCode
		--,(CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END) CODE
		--,(CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END) EngName
		,(D.Quantity)  Quantity
		,ROUND(ISNULL(D.SellingPrice, 0), 2) AS UNITPRICE
		, ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2) AS GROSS
		, ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2) AS DISCOUNT
		, ROUND(ISNULL(D.DeductAmount, 0), 2) AS DeductAmount
		,ROUND(ISNULL(D.PatientVat, 0), 2) AS PVAT
		, (ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) AS NET
		,ROUND(ISNULL(D.CompanyVat, 0), 2) AS CVAT
		, (ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2) AS CNET
		--,@FROMDATE FROMDATE
		--,@TODATE  TODATE
		
FROM TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON H.PatientClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN Nationalities N ON P.NationalityID = N.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID
	LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.ServiceItemID = I.ID AND AMID.AccountMainID = AM.ID
	--LEFT JOIN (SELECT H1.ID, MIN(H.TransNum) TransNum, MIN(H.TransDate) FROMDATE, MAX(H.TransDate) TODATE
	--		FROM TransHdr H
	--			JOIN TransHdr H1 ON H.ConsultationTransHdrID = H1.ID
	--		WHERE
	--			H.CancelDate IS NULL
	--			AND H.TransDate BETWEEN @FROMDATE AND @TODATE
	--		GROUP BY H1.ID, H1.TransNum
	--			) AS RELAT ON H.ConsultationTransHdrID = RELAT.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND H.InOut = 'O'
	AND I.ServiceGroupID <> 87
	AND AM.Code = CASE WHEN @MAINACCOUNT = '' THEN AM.Code ELSE @MAINACCOUNT END
	AND D.Quantity > 0
	) AS F

	--WHERE FileNum = 310608
	GROUP BY FileNum, PatientName, NAT, AccountName, MainAccount, DOCCODE, PayMethod
	ORDER BY MIN(FIRSTDATE), AccountName, FileNum
END