USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_ADMISSION_INFORMATION_BARCODE]    Script Date: 02/08/2018 11:18:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MAZEN F SULIMAN
-- Create date: 04/14/2018
-- Description:	BARCODE INFORMATION FOR ADMITTED PATIENT
-- =============================================
CREATE PROCEDURE [dbo].[sp_ADMISSION_INFORMATION_BARCODE] 
	@MRN INT = 0

AS
BEGIN
	SELECT
		  A.ID					AS ADMISSION_NUMBER 
		, AB.RegDate
		, P.FileNum				AS PATIENT_FILE_NUMBER
		, P.EngName				AS PATIENT_ENG_NAME
		, STR(YEAR(A.AdmDate) - YEAR(P.DOB)) + 'Y' AS AGE
		, P.Sex
		, A.AdmDate
		, D.Code				AS DOCTOR_CODE
		, D.EngName				AS DOCTOR_ENG_NAME
		, B.Code				AS BED_CODE

	FROM 
		Admissions			A
		JOIN Patients		P	ON A.PatientID		= P.ID
		JOIN Doctors		D	ON A.DoctorID		= D.ID
		JOIN AdmissionsBeds AB	ON AB.AdmissionID	= A.ID
		JOIN Beds			B	ON AB.BedID			= B.ID

	WHERE 
		A.DsgDate IS NULL
		AND P.FileNum = IIF(@MRN = 0, P.FileNum, @MRN)

	ORDER BY
		AB.RegDate DESC
END
