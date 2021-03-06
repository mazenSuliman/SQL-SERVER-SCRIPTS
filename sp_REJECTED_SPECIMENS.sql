USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_REJECTED_SPECIMENS]    Script Date: 02/08/2018 11:34:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_REJECTED_SPECIMENS]
	 @SERVICEITEM VARCHAR(50) = '%'
	,@SPECIALITY VARCHAR(50) = '%'
	,@DOCTOR	VARCHAR(50) = '%'
	,@FROMDATE SMALLDATETIME = '2017-12-01'
	,@TODATE SMALLDATETIME = '2017-12-31'
	,@INOUT		VARCHAR(10) = '%'
AS
BEGIN

	SET NOCOUNT ON;

    SELECT 
		  TDCFS.SpecimenNumber 
		 ,P.FileNum			AS MRN
		 ,P.EngName			AS PATIENT_NAME
		 ,YEAR(H.TransDate) - YEAR(P.DOB) AS AGE
		 ,CASE WHEN H.InOut = 'I' THEN 'IN' WHEN H.InOut = 'O' THEN 'OUT' END	AS LOCATION 
		 ,DS.EngName		AS DEPARTMENT
		 ,DO.EngName		AS DOCTOR_NAME
		 ,H.RegDate			AS TRANS_DATE
		 ,I.Code			AS ITEM_CODE
		 ,I.EngName			AS ITEM_NAME
		 ,TDCFS.RegDate		AS DATE_OF_SERVICE
		 ,U1.EngName		AS RECIEVED_BY
		 ,TDCFS.RecDate		AS REJ_DATE
		 ,U2.EngName		AS REJECTED_BY
		 ,TDCFS.Remarks
		 ,@FROMDATE			AS FROMDATE
		 ,@TODATE			AS TODATE

	FROM
		 TransDtlCustomFormsSpecimens TDCFS
		 JOIN TransDtl D			ON TDCFS.TransDtlsID	= D.ID
		 JOIN TransHdr H			ON D.TransHdrID			= H.ID
		 JOIN ServiceItems I		ON D.ServiceItemID		= I.ID
		 JOIN Patients P			ON H.PatientID			= P.ID
		 JOIN SystemUsers U1		ON TDCFS.RegUserID		= U1.ID
		 JOIN SystemUsers U2		ON TDCFS.RecUserID		= U2.ID
		 JOIN Doctors DO			ON H.DoctorID			= DO.ID
		 JOIN DoctorsSpecialties DS ON DO.DoctorSpecialtyID = DS.ID

	WHERE SpecimenStatus = 'REJ'
		 AND I.Code  = CASE WHEN @SERVICEITEM	= '%' THEN I.Code	ELSE @SERVICEITEM	END
		 AND DS.Code = CASE WHEN @SPECIALITY	= '%' THEN DS.Code	ELSE @SPECIALITY	END
		 AND DO.Code = CASE WHEN @DOCTOR		= '%' THEN DO.Code	ELSE @DOCTOR		END
		 AND H.InOut = CASE WHEN @INOUT			= '%' THEN  H.InOut ELSE @INOUT			END
		 AND TDCFS.RegDate BETWEEN @FROMDATE AND @TODATE

END