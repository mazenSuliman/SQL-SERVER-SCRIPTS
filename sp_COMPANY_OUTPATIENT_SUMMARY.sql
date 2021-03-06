USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_COMPANY_OUTPATIENT_SUMMARY]    Script Date: 02/08/2018 11:23:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_COMPANY_OUTPATIENT_SUMMARY]
	 @MAINACCOUNT VARCHAR(50) = '%'
	,@FROMDATE	smalldatetime = '2013-01-01'
	,@TODATE	smalldatetime = '2020-12-31'
AS
BEGIN
	SELECT	 VISIT_ID
			, P.OutSideRecNum 
			,P.FileNum							AS MRN
			,P.EngName							AS PATIENT_NAME
			,N.EngName							AS NATIONALITY
			,P.IdentityNo
			,CONVERT(DATE, H.REGDATE)			AS TRANSDATE
			,CONVERT(TIME, H.REGDATE)			AS TRANSTIME
			,DBO.[fn_HTGETRANK](H.ID, 'DIAG')	AS DAIG
			,DBO.[fn_HTGETRANK](H.ID, 'CC')		AS CC
			,DBO.[fn_HTGETRANK](H.ID, 'SS')		AS SS
			,DBO.[fn_HTGETRANK](H.ID, 'OS')		AS OS
			,RS.EngName							AS RESPCENTER
			,DO.EngName							AS DOCTOR
			,DS.EngName							AS SPEC
			,CASE WHEN ISNULL(H.IsConsultation,0) = 1 AND ISNULL(IsFreeRevisit,0) = 0 THEN 1 ELSE 0 END AS IS_CONS
			,ISNULL(H.IsFreeRevisit,0) AS ISREVISIT
			,H.InOut 
			,CASE WHEN ISNULL(TD.IsER, 0) = 1 THEN 'Y' ELSE 'N' END IS_EMERGANCY
			,H.TransNum
			--,AM.EngName
			--,AM.Code
			,CASE WHEN AMID.CoCode IS NULL OR AMID.CoCode = '' THEN I.Code ELSE AMID.CoCode END AS ITEMCODE
			, CASE WHEN AMID.CoDesc IS NULL OR AMID.CoDesc = '' THEN I.EngName ELSE AMID.CoDesc END AS NAMEOFITEM 
			,D.Quantity 
			,CASE WHEN RS.EngName  LIKE '%Pharmacy%' THEN 'M' ELSE 'D' END AS MEDICINE
			,ISNULL(D.SellingPrice, 0) AS UNITPRICE
			,H.TransDate
			,ISNULL(D.SellingPrice, 0)*D.Quantity AS GROSS
			,(ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity AS DISCOUNT
			,ISNULL(D.DeductAmount, 0) AS DeductAmount
			,ISNULL(D.PatientVat, 0) AS PVAT
			,(ISNULL(D.SellingPrice, 0)*D.Quantity) - ((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity + 
			(ISNULL(D.DeductAmount, 0) + ISNULL(D.InvoiceDeductAmount, 0))) AS NET
			,ISNULL(D.CompanyVat, 0) AS CVAT
			, ((ISNULL(D.SellingPrice, 0)*D.Quantity) - ((ISNULL(D.SellingPrice, 0) - ISNULL(D.ContractPrice, 0))*D.Quantity + 
			(ISNULL(D.DeductAmount, 0) + ISNULL(D.InvoiceDeductAmount, 0)))) + ISNULL(D.CompanyVat, 0) AS CNET
			,A.Code AS POLICY_NO
			,A.EngName AS POLICY_NAME
		
	FROM TransHdr H
			JOIN TransDtl D ON D.TransHdrID = H.ID
			JOIN Patients P ON H.PatientID = P.ID
			JOIN Doctors DO ON H.DoctorID = DO.ID
			JOIN PatientsClasses PC ON P.ClassID = PC.ID
			LEFT JOIN Accounts A ON H.AccountID = A.ID
			JOIN AccountsContracts AC ON AC.AccountID = A.ID
			JOIN AccountsMain AM ON AC.AccountMainID = AM.ID
			LEFT JOIN ServiceItems I ON D.ServiceItemID = I.ID
			JOIN Nationalities N ON P.NationalityID = N.ID
			JOIN RespCenters RS ON H.RespCenterID = RS.ID
			JOIN DoctorsSpecialties DS ON DO.DoctorSpecialtyID = DS.ID
			LEFT JOIN TransDtlMedicalData TD ON TD.TransDtlID = D.ID
			LEFT JOIN AccountsMainItemsDiscs AMID ON AMID.ServiceItemID = I.ID AND AMID.AccountMainID = AM.ID
			JOIN (SELECT H.PatientFileNum, COUNT(*) VISIT_ID
					FROM TransHdr H
					WHERE IsConsultation = 1 
						AND (IsFreeRevisit = 0 OR IsFreeRevisit IS NULL)
						AND H.CancelDate IS NULL
						AND H.TransDate BETWEEN '2018-01-01' AND '2018-01-15'
					GROUP BY H.PatientFileNum) AS VISITID ON P.FileNum = VISITID.PatientFileNum

	WHERE		AM.CODE = CASE WHEN @MAINACCOUNT	= '%'	THEN AM.CODE ELSE @MAINACCOUNT	END
			AND H.InOut = 'O'
			AND H.TransDate BETWEEN @FROMDATE AND @TODATE 
			AND H.CancelDate IS NULL
			AND D.Quantity > 0

ORDER BY A.Code, PC.EngName, P.FileNum
END