USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCUMENT_IN_WORKFLOW]    Script Date: 02/08/2018 11:28:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_DOCUMENT_IN_WORKFLOW]
		@TrnsEntryCode VarChar(50)='',
		@InitUserCode VarChar(50)='',
		@StageUserCode VarChar(50)='',
		@ActionCode VarChar(50)='',
		@DocumentCode VarChar(50)='',
		@PatientFileNo Int=0,
		@FromDate datetime= 0,
		@ToDate datetime= '31/12/2070'
AS
BEGIN
	set Dateformat DMY;
	SELECT DISTINCT Dwf_DocumentWorkFow.RegDate AS TrnsDate
,Dwf_DocumentWorkFow.TrnsEntryCode AS RequestNo,
(SELECT  Code from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) As RequestOwnerCode,
(SELECT  ArbName from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) AS RequestOwnerArb,
(SELECT  EngName from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) AS RequestOwnerEng,
isnull((SELECT  FileNum from Patients WHERE Patients.id = Dwf_DocumentWorkFow.Notes),'') AS PatientFileNo,
isnull((SELECT  EngName from Patients WHERE Patients.id = Dwf_DocumentWorkFow.Notes),'') AS PatientName,
CustomForms.Code AS DocumentCode,
CustomForms.ArbName AS DocumentArb,
CustomForms.EngName AS DocumentEng,
@FromDate AS FROMDATE,
@ToDate AS TODATE

From
Dwf_DocumentWorkFow	Inner Join Dwf_DocumentStages	On Dwf_DocumentStages.Code = Dwf_DocumentWorkFow.StageCode 
                    Inner Join CustomForms		On CustomForms.ID = Dwf_DocumentWorkFow.DocumentID 	
	                left Join Dwf_ActionTypes		On Dwf_ActionTypes.ID = Dwf_DocumentWorkFow.ActionID 
where 
(SELECT  Code from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) is not null
and  Dwf_DocumentWorkFow.TrnsEntryCode Like @TrnsEntryCode +'%'
and  (SELECT  Code from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) Like @InitUserCode +'%'
AND  (SELECT  Code from SystemUsers where ID = Dwf_DocumentWorkFow.PeopleID) Like @StageUserCode +'%'
and Dwf_ActionTypes.Code Like @ActionCode +'%'
and CustomForms.Code Like @DocumentCode +'%'
and  Dwf_DocumentWorkFow.RegDate between @FromDate And @ToDate

and (@PatientFileNo = '' or  ((case when Dwf_DocumentWorkFow.DocumentID = 402 then 
(SELECT  top 1 menu_tb4 from CF_SL where menu_tb1 = Dwf_DocumentWorkFow.TrnsEntryCode) 
else 
(SELECT  top 1 menu_tb4 from CF_SL where menu_tb1 = Dwf_DocumentWorkFow.TrnsEntryCode) 
end) = @PatientFileNo))
END
