SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mazen F. Suliman
-- Create date: 29/08/2018
-- Description:	Finding Approval Changes
-- =============================================
ALTER PROCEDURE sp_Approval_Changes 
	 @SERVICEITEM	VARCHAR(20)		= '%'
	,@MRN			INTEGER			= 0
	,@DOCTOR		VARCHAR(20)		= '%'
	,@SYSTEMUSER	VARCHAR(20)		= '%'
	,@FROMDATE		SMALLDATETIME	= '2000-01-01'
	,@TODATE		SMALLDATETIME	= '2100-12-31'
AS
BEGIN
	SELECT	  P.FileNum
		, P.EngName
		, C.RegDate
		, DO.Code
		, DO.EngName
		, D.ServiceItemCode
		, I.EngName
		, U.Code
		, U.EngName
		, D.RegDate
		, @FROMDATE
		, @TODATE

	FROM     ApprovalDtl	D
		JOIN ApprovalHdr	H  ON D.ApprovalHdrID	= H.ID
		JOIN ChangeHistory	C  ON C.RecordID		= D.ID
		JOIN PATIENTS		P  ON H.PatientID		= P.ID
		JOIN SystemUsers	U  ON C.RegUserID		= U.ID
		JOIN ServiceItems	I  ON D.ServiceItemID	= I.ID
		JOIN Doctors		DO ON D.DoctorID		= DO.ID

	WHERE H.PatientFileNum =IIF(@MRN = 0, H.PatientFileNum, @MRN)
		AND D.ServiceItemCode = IIF(@SERVICEITEM = '%', D.ServiceItemCode, @SERVICEITEM)
		AND C.RegUserID = IIF(@SYSTEMUSER = '%', C.RegUserID, @SYSTEMUSER)
		AND C.TableName = 'ApprovalDtl'
		AND C.FIELD LIKE 'ApprovalDate'
		AND C.RegDate BETWEEN @FROMDATE AND @TODATE
END
GO
