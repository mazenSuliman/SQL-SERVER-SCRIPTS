set Dateformat DMY;
DECLARE
		@TrnsEntryCode VarChar(50)='',
		@InitUserCode VarChar(50)='',
		@StageUserCode VarChar(50)='',
		@ActionCode VarChar(50)='',
		@DocumentCode VarChar(50)='',
		@PatientFileNo Int=0,
		@FromDate datetime= '22/03/2018',
		@ToDate datetime= '23/03/2018'
	
--DECLARE
--		@TrnsEntryCode VarChar(50)='',
--		@InitUserCode VarChar(50)='',
--		@StageUserCode VarChar(50)='',
--		@ActionCode VarChar(50)='',
--		@DocumentCode VarChar(50)='',
--		@PatientFileNo Int='',
--		@FromDate datetime='01/02/2018',
--		@ToDate datetime='12/02/2018'


		
SELECT DISTINCT Dwf_DocumentWorkFow.RegDate AS TrnsDate
,Dwf_DocumentWorkFow.TrnsEntryCode AS RequestNo,
(SELECT  Code from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) As RequestOwnerCode,
(SELECT  ArbName from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) AS RequestOwnerArb,
(SELECT  EngName from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople) AS RequestOwnerEng,
--(SELECT DISTINCT Code from SystemUsers where ID = Dwf_DocumentWorkFow.PeopleID) AS StagePersonCode,
--(SELECT DISTINCT ArbName from SystemUsers where ID = Dwf_DocumentWorkFow.PeopleID) AS StagePersonArb,
--(SELECT DISTINCT EngName from SystemUsers where ID = Dwf_DocumentWorkFow.PeopleID) AS StagePersonEng,
isnull((SELECT  FileNum from Patients WHERE Patients.id = Dwf_DocumentWorkFow.Notes),'') AS PatientFileNo,
isnull((SELECT  EngName from Patients WHERE Patients.id = Dwf_DocumentWorkFow.Notes),'') AS PatientName,
CustomForms.Code AS DocumentCode,
CustomForms.ArbName AS DocumentArb,
CustomForms.EngName AS DocumentEng
--Dwf_ActionTypes.Code AS ActionCode,
--Dwf_ActionTypes.ArbName AS ActionArb,
--Dwf_ActionTypes.EngName AS ActionEng,
--Dwf_DocumentWorkFow.RegDate

--dbo.fn_WFRetStatus(isnull(Dwf_ActionTypes.ID,0),ISNULL(Dwf_DocumentWorkFow.Status,0),1) AS StatusArb,
--dbo.fn_WFRetStatus(isnull(Dwf_ActionTypes.ID,0),ISNULL(Dwf_DocumentWorkFow.Status,0),2) AS StatusEng,

--Dwf_DocumentStages.Code,
--Dwf_DocumentStages.ArComment,
--Dwf_DocumentStages.EnComment
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

--order by (SELECT DISTINCT Code from SystemUsers where ID = Dwf_DocumentWorkFow.InitPeople),Dwf_DocumentWorkFow.TrnsEntryCode,Dwf_DocumentWorkFow.RegDate
--SELECT DISTINCT * from Dwf_DocumentWorkFow where DocumentID=13
--SELECT DISTINCT * from CustomForms where EngName like'%sick%'
