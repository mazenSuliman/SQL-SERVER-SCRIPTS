SET DATEFORMAT DMY
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


DECLARE
      @MRN                 int = 515151,
	  @FROMDATE			SMALLDATETIME = '06/06/2018',
	  @TODATE			SMALLDATETIME = '08/06/2018',
	 --@TransHdrID					Int = 0, 
	 --@TubeType                   VarChar(100)='', 
      @LabFormControlsGroupID		Int = 0
	 --@ConsThID		Int = 0

--Declare
--	@TransDtlID                 int = 0,
--	@TransHdrID					Int = 0, 
	--@LabFormControlsGroupID		INT = 0,
--	@TubeType                   VarChar(100)='',
--	@ConsThID                   int = 30290
 
SELECT

dbo.TransDtlLabFormsData.ID,
td.ServiceItemCode                                                                              AS ServiceItemCode,
dbo.ServiceItems.EngName                                                                        AS ServiceItemName,
dbo.LabForms.EngName                                                                            AS FormName,
dbo.LabFormControlsGroups.Caption																AS LabGroupName,
dbo.LabFormControls.Caption                                                                     AS LabControlName,
TransDtlLabFormsData.Data,
TransDtlLabFormsData.Info                                                                      AS Info,
NormalValue,
dbo.TransDtlCustomFormsSpecimens.ConfirmDate													AS ResaultDate,
dbo.TransDtlCustomFormsSpecimens.RegDate													    AS RecieveDate,
TH.TransNum,
CASE WHEN dbo.Patients.Sex = 'F' THEN 'FeMale' ELSE 'Male' END									AS Sex,
DOB																								AS Age,
dbo.Accounts.EngName                                                                            AS AccountEngName,
dbo.Accounts.ArbName                                                                            AS AccountArbName,
TH.PatientFileNum                                                                               AS MRN,
dbo.Patients.EngName                                                                            AS PatientEngName,
dbo.Patients.ArbName                                                                            AS PatientArbName,
CASE WHEN th.InOut = 'I' THEN Beds.Code  ELSE 'OPD' END									AS InOut,
CASE WHEN th.PayMethod = 'C' THEN 'Cash' ELSE 'Credit' END										AS PayMethod,
dbo.Doctors.EngName                                                                             AS DoctorEngName,
doctors.ArbName                                                                                 AS DoctorArbName,
dbo.Beds.Code                                                                                   AS BedCode,
LabFormControls.Rank                                                                            As ControlRank,
LabFormControlsGroups.Rank                                                                      As GroupRank,
ServiceItems.Remarks                                                                            As ServiceItemRemarks,
Nationalities.EngName                                                                           As Nationalities,
TransDtlLabFormsData.Unit                                                                       As Unit,
TransDtlCustomFormsSpecimens.SpecimenStatus,
S1.Code																							As LabDataUser,
S1.EngName																						As LabDataUserName,
S2.Code																							As SpecimenUser,
S2.EngName																						As SpecimenUserName,
S3.EngName																				As ConfirmUserName,
S3.Code																						As ConfirmUserCode,
(select Count(ID)  from TransHdr where CancelDate is null and PatientID = Patients.ID)					As Counting,
TH.RegDate																					As RegDate,
ServiceCats.EngName																			As Cat,
ServiceItems.ProgramService																	As SendOut
FROM
dbo.TransHdr TH								WITH (NOLOCK)
INNER JOIN dbo.TransDtl TD					WITH (NOLOCK)	ON th.ID                            = td.TransHdrID
Inner Join ServiceCats						WITH (NOLOCK)	on TD.ServiceCatID					= ServiceCats.ID
Inner join TransDtlCustomFormsSpecimens		WITH (NOLOCK)	on TransDtlCustomFormsSpecimens.TransDtlsID = TD.ID  And RTRIM(TransDtlCustomFormsSpecimens.SpecimenStatus) <> 'REJ' And RTRIM(TransDtlCustomFormsSpecimens.SpecimenStatus) <> 'CAN'
Inner JOIN dbo.TransDtlLabFormsData			WITH (NOLOCK)	ON TransDtlLabFormsData.TransDtlCustomFormSpecimenID =  TransDtlCustomFormsSpecimens.ID And TransDtlLabFormsData.CancelDate is null And TransDtlLabFormsData.Data is not null And TransDtlLabFormsData.Data <> ''
left Join SystemUsers S1						WITH (NOLOCK)	On S1.ID								= TransDtlLabFormsData.RegUserID
INNER JOIN dbo.Patients						WITH (NOLOCK)	ON th.PatientID                     = patients.ID
INNER JOIN dbo.Accounts						WITH (NOLOCK)	ON th.AccountID                     = dbo.Accounts.ID
INNER JOIN dbo.Doctors						WITH (NOLOCK)   ON th.DoctorID                      = doctors.ID
INNER JOIN dbo.ServiceItems					WITH (NOLOCK)   ON td.ServiceItemID					= dbo.ServiceItems.ID
INNER JOIN dbo.ServiceItemsSettings			WITH (NOLOCK)   ON ServiceItems.ID					= dbo.ServiceItemsSettings.ServiceItemID
LEFT JOIN dbo.Nationalities					WITH (NOLOCK)   ON Patients.NationalityID           = Nationalities.ID
Inner JOIN dbo.LabFormControls				WITH (NOLOCK)   ON TransDtlLabFormsData.LabFormControlID          = dbo.LabFormControls.ID
left Join SystemUsers S2						WITH (NOLOCK)	On S2.ID							= TransDtlCustomFormsSpecimens.RecUserID
LEFT JOIN dbo.LabFormControlsGroups			WITH (NOLOCK)   ON LabFormControls.LabFormControlsGroupID  = dbo.LabFormControlsGroups.ID
LEFT JOIN dbo.LabForms						WITH (NOLOCK)   ON LabFormControlsGroups.LabFormID                  = dbo.LabForms.ID
LEFT JOIN dbo.Admissions						WITH (NOLOCK)   ON th.AdmissionID                = admissions.ID
LEFT JOIN dbo.Beds							WITH (NOLOCK)   ON Beds.ID                       = Admissions.BedID
LEFT Join SystemUsers S3						WITH (NOLOCK)	On S3.ID							 = TransDtlCustomFormsSpecimens.ConfirmUserID
WHERE
((ISNULL(th.CancelDate,0) = 0 AND @LabFormControlsGroupID = 0)
OR (ISNULL(th.CancelDate,0) = 0 AND @LabFormControlsGroupID <> 0 AND LabFormControlsGroupID = @LabFormControlsGroupID)

) 
AND TH.TransDate BETWEEN @FROMDATE AND @TODATE
AND TH.PatientFileNum = CASE When @MRN = 0 Then TH.PatientFileNum Else @MRN End
--AND TD.ID = CASE When @TransDtlID = 0 Then TD.ID Else @TransDtlID End
--AND  TH.ConsultationTransHdrID = CASE When @ConsThID = 0 Then TH.ConsultationTransHdrID Else @ConsThID End
And LabFormControlsGroups.CancelDate is null
AND dbo.LabForms.EngName LIKE '%CULTURE%'
--And ServiceItemsSettings.TubeType like @TubeType +'%'
--AND RTRIM(TransDtlCustomFormsSpecimens.SpecimenStatus) = 'M'
--AND 
--LTRIM(RTRIM(TransDtlLabFormsData.Data)) <>''
order by LabFormControlsGroups.Rank , LabFormControls.Rank asc
