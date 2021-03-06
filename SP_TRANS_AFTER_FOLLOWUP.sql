USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_TRANS_AFTER_FOLLOWUP]    Script Date: 02/08/2018 11:36:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_TRANS_AFTER_FOLLOWUP] 
		 
		 @TRANSNUM		INT = 0
		,@SYSTEMUSER	VARCHAR(50)='%'
		,@FROMDATE		SMALLDATETIME = '2047-12-31'
		,@TODATE		SMALLDATETIME = '2007-01-01'
AS
BEGIN
	SELECT    A.PatientFileNum		AS PATIENT_FILE_NUMBER
				, A.TransNum			AS FOLLOWUP_TRANS_NUMBER
				, B.TransNum			AS CONSULTATION_TRANS_NUMBER
				, A.TransDate			AS FOLLOWUP_TRANS_DATE
				, B.TransDate			AS CONSULTATION_TRANS_DATE
				, A.RegDate				AS FOLLOW_DATETIME
				, B.RegDate				AS CONSULTATION_DATETIME
				, CASE WHEN A.CancelDate IS NOT NULL THEN 'TRUE' ELSE 'FALSE' END AS IS_FOLLOWUP_CANCELLED
				, CASE WHEN B.CancelDate IS NOT NULL THEN 'TRUE' ELSE 'FALSE' END AS IS_CONSULTATION_CANCELLED
				, A.ServiceItemCode		AS FOLLOWUP_ITEM_CODE
				, I1.EngName			AS FOLLOWUP_ITEM_NAME
				, B.ServiceItemCode		AS CONSULTATION_ITEM_CODE
				, I2.EngName			AS CONSULTATION_ITEM_NAME
				, A.RegUserCode			AS FOLLOWUP_USER_CODE
				, U1.EngName			AS FOLLOWUP_USER_NAME
				, G1.EngName			AS FOLLOWUP_DEPARTMENT
				, B.RegUserCode			AS CONSULTATION_USER_CODE
				, U2.EngName			AS CONSULTATION_USER_NAME
				, G2.EngName			AS CONSULTATION_DEPARTMENT
				, B.GrossAmount			AS AMOUNT
				, @FROMDATE				AS FROMDATE
				, @TODATE				AS TODATE
FROM
		(SELECT H.PatientFileNum ,H.TransDate, D.ServiceItemCode, H.RegDate, H.TransNum, H.RegUserCode, H.CancelDate FROM TransDtl D
			JOIN ServiceItems I ON D.ServiceItemCode = I.Code
			JOIN TransHdr H ON D.TransHdrID = H.ID
		WHERE I.EngName LIKE '%FOLLOW%'
			AND I.ServiceGroupID = (SELECT ID FROM ServiceGroups WHERE Code = 'CON')) AS A
	JOIN
		(SELECT H.PatientFileNum ,H.TransDate, D.ServiceItemCode, H.TransNum, H.RegDate, H.GrossAmount, H.RegUserCode, H.CancelDate FROM TransHdr H
				JOIN TransDtl D ON D.TransHdrID = H.ID
		WHERE H.IsConsultation = 1) AS B ON A.PatientFileNum = B.PatientFileNum 
	JOIN SystemUsers U1 ON A.RegUserCode = U1.Code
	JOIN SystemUsers U2 ON B.RegUserCode = U2.Code
	JOIN ServiceItems I1 ON A.ServiceItemCode = I1.Code
	JOIN ServiceItems I2 ON B.ServiceItemCode = I2.Code
	JOIN SystemGroupsUsers UG1 ON UG1.SystemUserID = U1.ID
	JOIN SystemGroups G1 ON UG1.SystemGroupID = G1.ID
	JOIN SystemGroupsUsers UG2 ON UG2.SystemUserID = U2.ID
	JOIN SystemGroups G2 ON UG2.SystemGroupID = G2.ID

WHERE A.TransDate BETWEEN B.TransDate AND DATEADD(DAY, 7, B.TransDate)
	AND A.RegDate < B.RegDate
	AND A.TransNum = CASE WHEN @TRANSNUM = 0 THEN A.TransNum ELSE @TRANSNUM END
	AND A.RegUserCode LIKE @SYSTEMUSER + '%'
	AND A.RegDate BETWEEN @FROMDATE AND @TODATE
END
