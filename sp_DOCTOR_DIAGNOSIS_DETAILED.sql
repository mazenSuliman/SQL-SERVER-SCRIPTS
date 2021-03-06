USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCTOR_DIAGNOSIS_DETAILED]    Script Date: 02/08/2018 11:24:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mazen Suliman
-- Create date: 21/04/2018
-- Description:	Detailed information about Diagnosis
-- =============================================
CREATE PROCEDURE [dbo].[sp_DOCTOR_DIAGNOSIS_DETAILED]
	 @FROMDATE	SMALLDATETIME	= '2016-01-01'
	,@TODATE	SMALLDATETIME	= '2038-12-31'
	,@DOCTOR	VARCHAR(15)		= '%'
	,@SPECIALTY	VARCHAR(25)		= '%'

AS
BEGIN
	SELECT P.FileNum
		,P.EngName														AS PATIENT_NAME	 
		,Do.Code														AS DOCTOR_CODE
		,Do.EngName														AS DOCTOR_NAME
		,Ds.EngName														AS SPECALITY
		,H.TransNum
		,H.TransDate
		,ICD.Code														AS DIAG_CODE
		,ICD.Description												AS DAIG_NAME
		,ICD.Code														AS REQEST_TIMES
		,@FROMDATE														AS FROMDATE
		,@TODATE														AS TODATE

	FROM   
		TransHdr						H 
		JOIN TransDtl					D		ON D.TransHdrID					= H.ID
		JOIN Doctors					Do		ON H.DoctorID					= Do.ID
		JOIN DoctorsSpecialties			Ds		ON Do.DoctorSpecialtyID			= Ds.ID
		JOIN PATIENTS					P		ON H.PatientID					= P.ID
		JOIN TransDtlMedicalData		TM		ON D.ID							= TM.TransDtlID
		JOIN TransDtlMedicalDataDtls	TMD		ON TMD.TransDtlMedicalDataID	= TM.id
		JOIN MedicalDataTypes			MT1		ON TMD.MedicalDataTypeID		= MT1.id
		JOIN ICDs						ICD		ON ICD.ID						= TMD.ICDID

	WHERE 
		H.CancelDate IS NULL
		AND TMD.CancelDate is null
		AND MT1.Code = 'DIAG'		
		AND H.TransDate BETWEEN @FROMDATE AND @TODATE
		AND Do.Code LIKE @DOCTOR	+ '%'
		AND Ds.Code LIKE @SPECIALTY + '%'
END
