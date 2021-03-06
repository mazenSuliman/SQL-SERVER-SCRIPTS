USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_COMPANIES_PAYMENTS03]    Script Date: 02/08/2018 11:23:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_COMPANIES_PAYMENTS03]
	 @MAINACCOUNT VARCHAR(50) = ''
	,@FROMDATE	SMALLDATETIME = '2017-01-01'
	,@TODATE	SMALLDATETIME = '2017-12-31'
AS
BEGIN
SELECT	CASE WHEN H.InOut = 'O' THEN 'Out Patients' WHEN H.InOut = 'I' THEN 'In Patients' END AS  InOut
		, AM.ENGNAME MAIN_NAME
		, A.Code ACCOUNT_CODE
		, A.EngName ACCOUNT_NAME
		, P.ClassID CLASS_ID
		,PC.EngName CLASS
		,CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END NAT
		,COUNT(DISTINCT P.FileNum) PAT_#
		,SUM(ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) AS GROSS
		,SUM(ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) AS DISCOUNT
		,SUM(ROUND(ISNULL(D.DeductAmount, 0), 2)) AS DeductAmount
		,SUM(ROUND(ISNULL(D.PatientVat, 0), 2)) AS PVAT
		,SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2))) AS NET
		,SUM(ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CVAT
		,SUM((ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) + ROUND(ISNULL(D.CompanyVat, 0), 2)) AS CNET
		,@FROMDATE FROMDATE
		
FROM     TransHdr H
	JOIN TransDtl D ON D.TransHdrID = H.ID
	JOIN Patients P ON H.PatientID = P.ID
	JOIN Doctors DO ON H.DoctorID = DO.ID
	JOIN PatientsClasses PC ON P.ClassID = PC.ID
	JOIN Accounts A ON H.AccountID = A.ID
	JOIN AccountsContracts AC ON AC.AccountID = A.ID
	JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
	JOIN ServiceItems I ON D.ServiceItemID = I.ID
	JOIN RespCenters RS ON H.RespCenterID = RS.ID

WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE
	AND H.CancelDate IS NULL
	AND AM.CODE = CASE WHEN @MAINACCOUNT = '' THEN AM.CODE ELSE @MAINACCOUNT END
	AND (ROUND(ISNULL(D.SellingPrice, 0)*D.Quantity, 2)) - (ROUND((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity, 2)) - (ROUND(ISNULL(D.DeductAmount, 0), 2)) > 0
GROUP BY AM.EngName, H.InOut,A.Code, A.EngName, P.ClassID, PC.EngName, CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END
ORDER BY H.InOut,A.Code, A.EngName, P.ClassID, PC.EngName, CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END DESC
END
