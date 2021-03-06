USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCTOR_TOP_N_DAIGNOSIS]    Script Date: 02/08/2018 11:25:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MAZEN SULIMAN
-- Create date: 03/31/2018
-- Description:	IN ORDER TO GET THE TOP DAIGNOSIS EACH DOCTOR HAD ISSUED
-- =============================================
CREATE PROCEDURE [dbo].[sp_DOCTOR_TOP_N_DAIGNOSIS] 
	 @FROMDATE	SMALLDATETIME	= '2017-01-01'
	,@TODATE	SMALLDATETIME	= '2020-12-31'
	,@DOCTOR	VARCHAR(15)		= '%'
	,@SPECIALTY	VARCHAR(25)		= '%'
	,@TOP		INT				= 5
AS
BEGIN
WITH DOCTOR_DIAG
AS(
	SELECT	DISTINCT	 
		 Do.Code																AS DOCTOR_CODE
		,MAX(Do.EngName)														AS DOCTOR_NAME
		,MAX(Ds.EngName)														AS SPECALITY
		,MAX(H.PatientFileNum)													AS FILE_NUM
		,ICD.Code																AS DIAG_CODE
		,MAX(ICD.Description)													AS DAIG_NAME
		,COUNT(ICD.Code)														AS REQEST_TIMES
		,ROW_NUMBER() OVER (PARTITION BY Do.CODE ORDER BY COUNT(ICD.Code) DESC) AS ROWNUMBER
		,@FROMDATE																AS FROMDATE
		,@TODATE																AS TODATE

	FROM   
		TransHdr						H 
		JOIN TransDtl					D		ON D.TransHdrID					= H.ID
		JOIN Doctors					Do		ON H.DoctorID					= Do.ID
		JOIN DoctorsSpecialties			Ds		ON Do.DoctorSpecialtyID			= Ds.ID
		JOIN TransDtlMedicalData		TM		ON D.ID							= TM.TransDtlID
		JOIN TransDtlMedicalDataDtls	TMD		ON TMD.TransDtlMedicalDataID	= TM.id
		JOIN MedicalDataTypes			MT1		ON TMD.MedicalDataTypeID		= MT1.id
		LEFT JOIN ICDs					ICD		ON ICD.ID						= TMD.ICDID

		
	WHERE 
		H.CancelDate IS NULL
		AND TMD.CancelDate is null
		AND MT1.Code = 'DIAG'
		
		AND H.TransDate BETWEEN @FROMDATE AND @TODATE
		AND Do.Code LIKE @DOCTOR	+ '%'
		AND Ds.Code LIKE @SPECIALTY + '%'

	GROUP BY 
		 Do.Code
		,ICD.Code
		)

SELECT * FROM DOCTOR_DIAG
WHERE ROWNUMBER <= IIF(@TOP <= 0 OR @TOP > 10, 5, @TOP)
ORDER BY DOCTOR_CODE, ROWNUMBER
END
