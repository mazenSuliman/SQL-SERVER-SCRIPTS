USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_COMPANIES_PAYMENTS04]    Script Date: 02/08/2018 11:23:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_COMPANIES_PAYMENTS04]
	@MAINACCOUNT VARCHAR(50) = ''
	,@FROMDATE  SMALLDATETIME = '2017-10-01'
	,@TODATE  SMALLDATETIME = '2017-10-31'
AS
BEGIN
	SELECT DISTINCT  ACM.Code
		,ACM.EngName
		,AC.Code
		,AC.EngName
		,P.FileNum
		,P.EngName
		,PC.EngName
		,A.AdmNum
		,A.AdmDate 
		,A.DsgDate
		,I.InvoiceNum
		,ISNULL(PACKAGES.GROSS, 0) + ISNULL(I.GrossAmount, 0) GROSS
		,ISNULL(PACKAGES.DIS, 0) + ISNULL(I.DiscAmount, 0) DIS
		,ISNULL(I.PaidAmount, 0) DEDUCT
		,(ISNULL(PACKAGES.GROSS, 0) + ISNULL(I.GrossAmount, 0)) - (ISNULL(PACKAGES.DIS, 0) + ISNULL(I.DiscAmount, 0)) - ISNULL(I.PaidAmount, 0) NET
		,@FROMDATE fromdate
		,@TODATE	todate

	FROM Invoices I
		JOIN Admissions A				ON I.AdmissionID		= A.ID
		JOIN Patients P					ON A.PatientID			= P.ID
		JOIN PatientsClasses PC			ON P.ClassID			= PC.ID
		JOIN Accounts AC				ON A.AccountID			= AC.ID
		JOIN AccountsContracts ACC		ON ACC.AccountID		= AC.ID
		JOIN AccountsMain ACM			ON ACC.AccountMainID	= ACM.ID
		LEFT JOIN (SELECT AdmissionID, SUM(AdmissionPrice) GROSS, SUM(IsNull(AdmissionPrice * (AdmissionDiscount/100),0)) DIS FROM AdmissionsPackages GROUP BY AdmissionID) AS PACKAGES ON PACKAGES.AdmissionID = A.ID

	WHERE ACM.Code = CASE WHEN @MAINACCOUNT = '' THEN ACM.Code ELSE @MAINACCOUNT END
		AND A.DsgDate BETWEEN @FROMDATE AND @TODATE
		AND I.InOut = 'I'
		AND (I.PayMethod = 'R' AND ACM.Code <> '101')
		AND I.CancelDate IS NULL

	ORDER BY ACM.Code, AC.Code, P.FileNum
END
