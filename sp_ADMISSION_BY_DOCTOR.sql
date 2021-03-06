USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_ADMISSION_BY_DOCTOR]    Script Date: 02/08/2018 11:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[sp_ADMISSION_BY_DOCTOR]

@DOCTOR VARCHAR = '%',
@FromDate					SMALLDATETIME = '01/01/2000' ,
@ToDate						SMALLDATETIME = '31/12/2059'

AS

set dateformat dmy
Select P.FileNum 
	, P.EngName		AS PAT_NAME
	, D.Code		AS RequsetedByDoc
	, D.EngName		AS RequsetedByDocName
	, AR.RegDate 
	, D2.Code		AS AdmByDoc 
	, D2.EngName	AS AdmDocName
	, A.AdmDate 
	, A.DsgDate
	, @FromDate		AS FROMDATE
	, @ToDate		AS TODATE

From AdmissionsRecommendations AR
	inner join Admissions A		on A.ID = AR.AdmissionID
	Inner Join Doctors D		On AR.DoctorID = D.ID
	inner join Doctors D2		on A.DoctorID = D2.ID
	Inner Join Patients P		On P.ID = AR.PatientID
Where D.Code like  @DOCTOR + '%'
And AR.RegDate  between @FromDate and @ToDate
