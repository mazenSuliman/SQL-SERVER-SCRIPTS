USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_COMPANIES_PAYMENTS02]    Script Date: 02/08/2018 11:22:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_COMPANIES_PAYMENTS02]
	 @MRN INT = 0
	,@FROMDATE	SMALLDATETIME = '2018-01-01'
	,@TODATE	SMALLDATETIME = '2018-01-01'
AS
BEGIN

SELECT	 P.FileNum AS MRN
		,P.EngName AS PNAME
		,P.OutSideRecNum AS MEMNUM
		,IV.InvoiceNum
		,AMD.CoDesc PACKAGENAME
		,AMD.CoCode PACKAGECODE
		,IV.InvoiceDate
		--,AP.ContractPrice
		,AD.AdmDate	
		,AD.DsgDate
		,PC.EngName AS CLASS
		,AM.EngName AS MAINACCOUNT
		,H.TransNum
		,H.TransDate
		,RS.EngName AS RESCENTER
		,A.EngName AS ACCOUNT
		,A.Code AS ACCODE
		,DO.EngName AS DOCTOR
		,CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END ITEMCODE
		, CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END ITEMNAME
		,D.Quantity
		,ISNULL(D.SellingPrice, 0) AS UNITPRICE
		,ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2) AS GROSS
		,ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2) AS DISCOUNT
		,ROUND(ISNULL(D.DeductAmount, 0), 2) AS DeductAmount
		,(ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) AS NET
		,@FROMDATE FROMDATE
		,@TODATE  TODATE		
		
FROM TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON P.ClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID
	LEFT JOIN Admissions AD ON H.AccountID = AD.ID
	LEFT JOIN AdmissionsPackages AP ON AP.AdmissionID = AD.ID
	LEFT JOIN ServiceItems I2 ON I2.ID = AP.ServiceItemID
	LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.AccountMainID = AM.ID AND AMID.ServiceItemID = I.ID
	LEFT JOIN (SELECT  DISTINCT A.ID, M.ServiceItemID, M.CoCode, M.CoDesc, M.PackagePrice FROM Admissions A
			JOIN AdmissionsPackages P ON P.AdmissionID = A.ID
			JOIN ServiceItems I ON P.ServiceItemID = I.ID
			JOIN AccountsMainItemsDiscs M ON I.ID = M.ServiceItemID) AS AMD ON AMD.PackagePrice = AP.ContractPrice
			JOIN Invoices IV ON H.InvoiceID = IV.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND H.InOut = 'I'
	AND H.PatientFileNum = @MRN
	--AND D.Quantity > 0
END