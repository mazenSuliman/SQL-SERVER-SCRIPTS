USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_COMPANIES_PAYMENTS01]    Script Date: 02/08/2018 11:22:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_COMPANIES_PAYMENTS01]
	 @MAINACCOUNT VARCHAR(50) = ''
	,@FROMDATE	SMALLDATETIME = '2017-01-01'
	,@TODATE	SMALLDATETIME = '2017-12-31'

AS
BEGIN
SELECT	 MAX(P.FileNum) FileNum
		,MAX(P.EngName) EngName
		,MAX(P.OutSideRecNum) OutSideRecNum
		,MAX(CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END) AS NAT
		,MAX(PC.EngName) EngName
		,MAX(AM.EngName) EngName
		,MAX(H.TransNum) TransNum
		,MAX(H.TransDate) TransDate
		,MAX(RS.EngName) EngName
		,MAX(A.EngName) EngName
		,MAX(A.Code) Code
		,MAX(DO.EngName) EngName
		,MAX(CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END) CODE
		,MAX(CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END) EngName
		,SUM(D.Quantity) Quantity
		,SUM(ISNULL(D.SellingPrice, 0)) AS UNITPRICE
		,SUM(ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2))  AS GROSS
		,SUM(ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2))  AS DISCOUNT
		,SUM(ROUND(ISNULL(D.DeductAmount, 0), 2))  AS DeductAmount
		,SUM(ROUND(ISNULL(D.PatientVat, 0), 2))  AS PVAT
		,SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)))  AS NET
		,SUM(ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CVAT
		, SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CNET
		,@FROMDATE FROMDATE
		,@TODATE  TODATE
		
FROM TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON H.PatientClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID
	LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.ServiceItemID = I.ID AND AMID.AccountMainID = AM.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND H.InOut = 'O'
	AND AM.CODE = CASE WHEN @MAINACCOUNT = '' THEN AM.CODE ELSE @MAINACCOUNT END
	AND I.ServiceGroupID = 87
	--AND D.Quantity > 0

GROUP BY H.PatientFileNum, H.DoctorCode, H.TransDate, I.ServiceGroupID, D.ServiceItemCode
HAVING SUM(D.Quantity) > 0

UNION ALL

SELECT	 (P.FileNum) FileNum
		,(P.EngName) EngName
		,(P.OutSideRecNum) OutSideRecNum
		,(CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END) AS NAT
		,(PC.EngName) EngName
		,(AM.EngName) EngName
		,(H.TransNum) TransNum
		,(H.TransDate) TransDate
		,(RS.EngName) EngName
		,(A.EngName) EngName
		,(A.Code) Code
		,(DO.EngName) EngName
		,(CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END) CODE
		,(CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END) EngName
		,(D.Quantity)  Quantity
		,ROUND(ISNULL(D.SellingPrice, 0), 2) AS UNITPRICE
		, ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2) AS GROSS
		, ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2) AS DISCOUNT
		, ROUND(ISNULL(D.DeductAmount, 0), 2) AS DeductAmount
		,ROUND(ISNULL(D.PatientVat, 0), 2) AS PVAT
		, (ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) AS NET
		,ROUND(ISNULL(D.CompanyVat, 0), 2) AS CVAT
		, (ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2) AS CNET
		,@FROMDATE FROMDATE
		,@TODATE  TODATE
		
FROM TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON H.PatientClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID
	LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.ServiceItemID = I.ID AND AMID.AccountMainID = AM.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND H.InOut = 'O'
	AND AM.CODE = CASE WHEN @MAINACCOUNT = '' THEN AM.CODE ELSE @MAINACCOUNT END
	AND I.ServiceGroupID <> 87
	AND D.Quantity > 0

END