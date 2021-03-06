USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_LAB_TAT_DAYS]    Script Date: 02/08/2018 11:31:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LAB_TAT_DAYS]
		@FromDate					DATETIME	= '2007-01-01 00:00:00' ,
		@ToDate						DATETIME	= '2047-12-31 23:59:59' ,
		@SERVICECAT					varchar(40)		= '%',
		@SERVICEITEM				varchar(40)		= '%'
		,@MRN			VARCHAR(50)		= '%'
		,@SYSTEMUSER				VARCHAR(50)		= '%'	
		,@LABNUM			VARCHAR(50)		= '%'
		,@SpecimenNumber	VARCHAR(50)		= '%'
AS
BEGIN
	SELECT	DISTINCT  P.FileNum
		, I.Code																											AS SERV
		, I.EngName																											AS SERV_NAME
		, SC.EngName																										AS CAT
		, LabNumber
		, SpecimenNumber
		, SP.RegDate
		, REGU.EngName																											AS REGUSERNAME
		, SP.ConfirmDate
		, CONU.EngName																											AS CONFIRMUSERNAME
		, 1.0*ISNULL(DATEDIFF(MINUTE, SP.REGDATE, SP.CONFIRMDATE),0)/60/24																AS DIFF_IN_DAYS
		, @FROMDATE																												AS FROMDATE
		, @TODATE																												AS TODATE

FROM	TransDtlCustomFormsSpecimens			AS SP 						
		INNER JOIN TransDtl 						AS D						ON SP.TransDtlsID 			= D.ID
		INNER JOIN TransHdr							AS H						ON D.TransHdrID 			= H.ID
		INNER JOIN ServiceItems						AS I						ON D.ServiceItemID 			= I.ID
		INNER JOIN ServiceItemsCats					AS C						ON C.ServiceItemID 			= I.ID
		INNER JOIN ServiceCats						AS SC						ON C.ServiceCatID 			= SC.ID
		INNER JOIN TransDtlLabFormsData				AS L						ON L.TransDtlID 			= D.ID
		INNER JOIN LabFormControls					AS F						ON F.ID 					= L.LabFormControlID
		INNER JOIN LabFormControlsGroups			AS G						ON F.LabFormControlsGroupID = G.ID
		INNER JOIN LabForms							AS LF						ON G.LabFormID 				= LF.ID
		INNER JOIN Doctors							AS DOC						ON H.DoctorCode 			= DOC.CODE
		INNER JOIN DoctorsSpecialties				AS SEP						ON DOC.DoctorSpecialtyID	= SEP.ID
		INNER JOIN Patients							AS P						ON P.ID						= H.PatientID
		INNER JOIN SystemUsers						AS CONU						ON SP.ConfirmUserID			= CONU.ID
		INNER JOIN SystemUsers						AS REGU						ON SP.RegUserID				= REGU.ID

WHERE	H.CancelDate Is Null
	AND I.ServiceGroupID = 26
	And	SP.ConfirmDate			Between @FromDate + '00:00:00' And @ToDate + '23:59:59'
	And	SC.Code						Like @ServiceCat	+ '%'
	AND I.CODE					LIKE @SERVICEITEM + '%'
	AND CONU.Code				LIKE @SYSTEMUSER + '%'
	AND P.FileNum LIKE @MRN + '%'
		AND SP.LabNumber LIKE @LABNUM + '%'
		AND SP.SpecimenNumber LIKE @SpecimenNumber + '%'
END
