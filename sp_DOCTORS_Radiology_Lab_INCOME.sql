USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCTORS_Radiology_Lab_INCOME]    Script Date: 02/08/2018 11:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[sp_DOCTORS_Radiology_Lab_INCOME]
	@SPECIALITY					varchar(30)		= '%',
	@ACCOUNT					varchar(30)		= '%',
	@FromDate					SMALLDATETIME	= '2007-01-01' ,
	@ToDate						SMALLDATETIME	= '2047-12-31'

As

SELECT		DISTINCT	  D.EngName						AS Name
				, D.DoctorSpecialtyID			AS Spec
				, CASt (d.Code AS varchar(20))	AS code
				, [DoctorsSpecialties].EngName	AS SpecName
				, ISNULL(Consultation.Price, 0)	AS Consultation
				, ISNULL(Consultation.Qty, 0)	AS ConsultationQty
				, ISNULL(Radiology.Price, 0)	AS Radiology
				, ISNULL(Radiology.Qty, 0)		AS RadiologyQty
				, ISNULL(Lab.Price, 0)			AS Lab
				, ISNULL(Lab.Qty, 0)			AS LabQty
				, ISNULL(ADM.Qty, 0)			AS ADMQTY
				, IIF(@ACCOUNT = '%', 'All Accounts', (SELECT ENGNAME FROM Accounts WHERE Code = @ACCOUNT)) AS ACCOUNT
				, @FromDate						AS fromdate
				, @ToDate						AS todate
				
				
FROM [ALDar_Hospital].[dbo].Doctors AS D 

LEFT JOIN (
  Select DISTINCT [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(PatientID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
		INNER JOIN [ALDar_Hospital].[dbo].Accounts A ON TransHdr.AccountID = A.ID
	Where TransHdr.IsConsultation = 1
		AND ISNULL(TransHdr.IsFreeRevisit, 0) = 0
		AND  [TransHdr].TransDate between @FromDate and @ToDate
		AND InOut = 'O'
		AND [ALDar_Hospital].[dbo].[TransHdr].CancelDate IS NULL
		AND A.Code = CASE WHEN @ACCOUNT = '%' THEN A.Code ELSE @ACCOUNT END
	Group by [DoctorCode])
AS Consultation ON D.Code = Consultation.[DoctorCode]
 
LEFT JOIN (
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(DISTINCT PatientID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
		INNER JOIN [ALDar_Hospital].[dbo].Accounts A ON TransHdr.AccountID = A.ID
	Where TransDtl.ServiceGroupID IN (25, 24, 30, 31)
		AND  [TransHdr].TransDate between @FromDate and @ToDate
		AND InOut = 'O'
		AND [ALDar_Hospital].[dbo].[TransHdr].CancelDate IS NULL
		AND A.Code = CASE WHEN @ACCOUNT = '%' THEN A.Code ELSE @ACCOUNT END
	Group by [DoctorCode])
AS Radiology ON D.Code = Radiology.[DoctorCode]

LEFT JOIN ( 
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT( DISTINCT PatientID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
		INNER JOIN [ALDar_Hospital].[dbo].Accounts A ON TransHdr.AccountID = A.ID
	Where TransDtl.ServiceGroupID = 26
		AND  [TransHdr].TransDate between @FromDate and @ToDate
		AND InOut = 'O'
		AND [ALDar_Hospital].[dbo].[TransHdr].CancelDate IS NULL
		AND A.Code = CASE WHEN @ACCOUNT = '%' THEN A.Code ELSE @ACCOUNT END
	Group by [DoctorCode])
AS Lab ON D.Code = Lab.[DoctorCode]

LEFT JOIN ( 
  Select  [DoctorID]
		, COUNT(PatientID) As Qty
	From [ALDar_Hospital].[dbo].[Admissions] 
		INNER JOIN [ALDar_Hospital].[dbo].Accounts A ON Admissions.AccountID = A.ID
	Where Admissions.AdmDate between @FromDate and @ToDate
		AND [ALDar_Hospital].[dbo].[Admissions].CancelDate IS NULL
		AND A.Code = CASE WHEN @ACCOUNT = '%' THEN A.Code ELSE @ACCOUNT END
	Group by DoctorID)
AS ADM ON D.ID = ADM.DOCTORID

LEFT JOIN [ALDar_Hospital].[dbo].[TransHdr] ON D.Code = [ALDar_Hospital].[dbo].[TransHdr].[DoctorCode]
INNER JOIN [ALDar_Hospital].[dbo].[DoctorsSpecialties] ON D.DoctorSpecialtyID = [ALDar_Hospital].[dbo].[DoctorsSpecialties].[ID]
--INNER JOIN [ALDar_Hospital].[dbo].Accounts A ON TransHdr.AccountID = A.ID

WHERE DoctorsSpecialties.Code = CASE WHEN @SPECIALITY = '%' THEN DoctorsSpecialties.Code ELSE @SPECIALITY END
		AND (ISNULL(Consultation.Qty, 0) <> 0)
		