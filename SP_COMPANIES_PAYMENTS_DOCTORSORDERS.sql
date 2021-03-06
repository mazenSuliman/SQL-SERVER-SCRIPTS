USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_COMPANIES_PAYMENTS_DOCTORSORDERS]    Script Date: 02/08/2018 11:21:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_COMPANIES_PAYMENTS_DOCTORSORDERS]
	@MAINACCOUNT 	VARCHAR(12)		= '40',
	@MRN			INT				= 0,
	@DOCTOR			VARCHAR(35)		= '%',
	@FROMDATE		SMALLDATETIME	= '2017-10-01',
	@TODATE			SMALLDATETIME	= '2017-10-30',
	@OnlyPharmacy	INT				= 0,
	@LANG			INT				= 0

AS
BEGIN
	Select
	AccountCode,
    dbo.fn_GetName(Accounts.EngName, Accounts.ArbName, @Lang)                                   As AccountName,
    PatientFileNum																				As MRNum,
	dbo.fn_GetName(Patients.EngName, Patients.ArbName, @Lang)									As MRName,
    Doctors.Code																				As DoctorCode,
	dbo.fn_GetName(Doctors.EngName, Doctors.ArbName, @Lang)										As DoctorName,
    RespCenters.Code																			As RespCenterCode,
	dbo.fn_GetName(RespCenters.EngName, RespCenters.ArbName, @Lang)								As RespCenterName,
    SystemUsers.Code																			As SystemUserCode,
	dbo.fn_GetName(RespCenters.EngName, RespCenters.ArbName, @Lang)								As SystemUserName,
	SystemGroups.Code																			As SystemGroupCode,
	dbo.fn_GetName(RespCenters.EngName, RespCenters.ArbName, @Lang)								As SystemGroupName,
	RequestNum,
	TransNum,
	TransDate,
    ServiceItemCode																					As ItemCode,
	dbo.fn_GetName(ServiceItems.EngName, ServiceItems.ArbName, @Lang)								As ItemName,
	IsNull(DosageText, '') +
	IsNull((Select EngName + ' '  From ServiceDosageFrequencies Where FrequencyID = ID), '') + ' / ' + 
	IsNull((Select EngName  From ServiceDosageDurations Where DurationID = ID), '') + ' / ' + 
	IsNull((Select EngName + ' '  From ServiceDosageRoutes Where RouteID = ID), '')  + IsNull(DoseNotes, '') As DosageText,
	IsNull(SellingPrice, 0) * IsNull(Quantity, 0)													As GrossAmount,
	IsNull(Quantity, 0)																				As Quantity,
	(IsNull(SellingPrice, 0) - IsNull(ContractPrice, 0)) * IsNull(Quantity, 0)						As DiscountAmount,
	IsNull(TransDtlIM.DeductAmount, 0) * IsNull(Quantity, 0)										As DeductAmount,
	(IsNull(ContractPrice, 0) - IsNull(TransDtlIM.DeductAmount, 0)) * IsNull(Quantity, 0)			As NetAmount,
	Year(GetDate()) - Year(DOB)																		As Age,
	Case when Sex = 'F' Then 'Female' Else 'Male' End												As Sex,
	(dbo.fn_UCAF_MEDData((Case When IsNull(FreeRevisitID,0)=0 Then
	 TH.ConsultationTransHdrID Else FreeRevisitID End ) , PatientID, 'DIAG',''))						As DIAGNOSIS,
	AccountsMain.Code + '-'+	dbo.fn_GetName(AccountsMain.EngName, AccountsMain.ArbName, @Lang)	As AccountMain,
	(select TransNum from TransHdr 
			where transhdr.ID = th.ConsultationTransHdrID)			As ConsTransNum,
	Case When RespCenters.RespCenterType = 'P' Then 2 Else 1 End									As NoOfPrint,
	1																								As PrintCAF,
	RespCenterType,
	dbo.fn_GetName(NT.EngName, NT.ArbName, @Lang)													As Nationality,
	dbo.fn_GetName(DS.EngName, DS.ArbName, @Lang)													As DoctorSpeciality,
	''																								As SignImage,
	dbo.fn_PatientsAllergies(th.PatientID)															As PatAllergy


From TransHdrIM TH
    Inner Join Accounts					ON TH.AccountID						= Accounts.ID
    left  Join AccountsContracts		ON Accounts.ID						= AccountsContracts.AccountID
    left  Join AccountsMain				ON AccountsContracts.AccountMainID	= AccountsMain.ID
    Inner Join Patients					ON TH.PatientID						= Patients.ID
	Inner Join RespCenters				ON TH.RespCenterID					= RespCenters.ID
	Inner Join Doctors					ON TH.DoctorID						= Doctors.ID
	Inner Join SystemUsers				ON TH.RegUserID						= SystemUsers.ID
	Left Join SystemGroups				ON TH.RegGroupID					= SystemGroups.ID
    Inner Join TransDtlIM				ON TH.ID							= TransDtlIM.TransHdrID
    Inner Join ServiceItems				ON TransDtlIM.ServiceItemID			= ServiceItems.ID
    Left Join  Nationalities		NT	ON Nt.ID							= Patients.NationalityID
    Left Join  DoctorsSpecialties	DS	ON DS.ID							= Doctors.DoctorSpecialtyID

Where AccountsMain.Code = CASE WHEN @MAINACCOUNT = '%' THEN AccountsMain.Code ELSE @MAINACCOUNT END
	AND TH.PatientFileNum = CASE WHEN @MRN = 0 THEN TH.PatientFileNum ELSE @MRN END
	AND TH.DoctorCode = CASE WHEN @DOCTOR = '%' THEN TH.DoctorCode ELSE @DOCTOR END
	AND TH.RespCenterCode = CASE WHEN @OnlyPharmacy = 1 THEN 'PCYO' ELSE TH.RespCenterCode END
	AND TH.TransDate BETWEEN @FROMDATE AND @TODATE
	AND TH.CancelDate IS NULL
				

END
