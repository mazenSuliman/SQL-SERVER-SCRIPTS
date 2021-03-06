USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_LAB_TAT]    Script Date: 02/08/2018 11:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_LAB_TAT] 
		@FromDate					DATETIME	= '2007-01-01',
		@FromTime					varchar(50)     ='00:00',
		@ToDate						DATETIME	= '2047-12-31', 
		@ToTime						varchar(50)     ='23:59',
		@SERVICECAT					varchar(40)		= '%',
		@SERVICEITEM				varchar(40)		= '%'
		,@MRN						VARCHAR(50)		= '%'
		,@SYSTEMUSER				VARCHAR(50)		= '%'	
		,@LABNUM					VARCHAR(50)		= '%'
		,@SpecimenNumber			VARCHAR(50)		= '%'
AS
BEGIN
	SELECT	DISTINCT  P.FileNum
		, I.Code																												AS SERV
		, I.EngName																												AS SERV_NAME
		, SC.EngName																											AS CAT
		, LabNumber
		, SpecimenNumber
		, SP.RegDate
		, REGU.EngName																											AS REGUSERNAME
		, SP.ConfirmDate
		, CONU.EngName																											AS CONFIRMUSERNAME
		, CASE WHEN FORMAT(CONVERT(datetime, SP.ConfirmDate - SP.RegDate), 'd ') = '1 ' 
			 THEN FORMAT(CONVERT(datetime, SP.ConfirmDate - SP.RegDate), '0 D HH:mm')
			 ELSE FORMAT(CONVERT(datetime, DATEADD(day, -1, SP.ConfirmDate) - CONVERT(datetime, SP.RegDate)), 'd D HH:mm') END	AS DIFF_IN_DHM
		, ISNULL(DATEDIFF(MINUTE, SP.REGDATE, SP.CONFIRMDATE),0)																AS DIFF_IN_M
		, I.Duration - 	ISNULL(DATEDIFF(MINUTE, SP.REGDATE, SP.CONFIRMDATE),0)													AS Duration
		, CASE WHEN I.Duration - 	ISNULL(DATEDIFF(MINUTE, SP.REGDATE, SP.CONFIRMDATE),0) < 0 THEN 1 ELSE 0 END				AS COUNT_NEG
		, @FROMDATE																												AS FROMDATE
		, @TODATE																												AS TODATE
		, @FromTime																												AS FROMTIME
		, @ToTime																												AS TOTIME

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
	AND CAST(SP.ConfirmDate AS dateTIME)  BETWEEN @FROMdate AND @todate+1
	AND RIGHT('00' + CAST(Datepart(hour ,SP.ConfirmDate) AS varchar) ,2)+ ':' + RIGHT( '00' + CAST(DATEPART(minute,SP.ConfirmDate) AS varchar)  ,2)   BETWEEN @FromTime AND @ToTime
	
	And	SC.Code						Like @ServiceCat	+ '%'
	AND I.CODE						LIKE @SERVICEITEM + '%'
	AND CONU.Code					LIKE @SYSTEMUSER + '%'
	AND P.FileNum					LIKE @MRN + '%'
	AND SP.LabNumber				LIKE @LABNUM + '%'
	AND SP.SpecimenNumber			LIKE @SpecimenNumber + '%'
END