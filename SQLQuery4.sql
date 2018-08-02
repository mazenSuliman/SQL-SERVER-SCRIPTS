Set DateFormat DMY

DECLARE
	@FromDate		datetime = '01/05/2017',
	@ToDate			datetime = '31/12/2017',
	@AccountCode	varchar(20) = '',
	@PayMethod	varchar(1) = '',
	@DoctorCode		varchar(20) = '',
	@MRN			int = 0,
	@BedCode		varchar(20) = '',
	@BedLoc			varchar(20) = '',
	@BedClass		varchar(20) = '',
	@Lang			int = 0
	
SELECT
	--ABC.ArbName, ABC.AccountCode, 
	COUNT(*) NUMBER_OF_ADMISSION
FROM(
Select  DISTINCT
			PatientID,
			AdmDate,
			DoctorsSpecialties.ArbName,
			CASE WHEN AM.EngName = 'MOH' THEN 'صحة' WHEN AM.EngName = 'CASH' THEN 'نقدي' ELSE 'آجل' END As AccountCode
 

From 		
	Admissions
	Inner Join 	Beds			On Admissions.BedID		 = Beds.ID
	Inner Join 	BedsClasses		On Admissions.BedClassID = BedsClasses.ID
	Inner Join 	BedsDepartments	On Beds.BedDepartmentID  = BedsDepartments.ID
	Inner Join 	Doctors			On Admissions.DoctorID   = Doctors.ID
    Inner Join 	Patients   		On Admissions.PatientID  = Patients.ID
	Inner Join	Accounts		On Admissions.AccountID  = Accounts.ID
	INNER JOIN AccountsContracts AC ON AC.AccountID = Accounts.ID
	INNER JOIN AccountsMain		AM ON AC.AccountMainID = AM.ID
	INNER JOIN DoctorsSpecialties ON Doctors.DoctorSpecialtyID = DoctorsSpecialties.ID

Where 
		IsNull(Admissions.CancelDate, 0) = 0
And 	AdmDate							Between @FromDate And @ToDate
--And		IsNull(Accounts.Code, '') 		Like @AccountCode + '%'
--And		IsNull(Admissions.PayMethod, '') 		Like @PayMethod + '%'
--And     IsNull(Doctors.Code, '')		Like @DoctorCode 
--And		Patients.FileNum 				= Case When @MRN = 0 Then Patients.FileNum Else @MRN End	
--And		IsNull(Beds.Code,'')			Like @BedCode + '%'
--And		IsNull(BedsDepartments.Code,'')	Like @BedLoc + '%'
--And  	IsNull(BedsClasses.Code, '')	Like @BedClass + '%'
)  AS ABC
GROUP BY ABC.ArbName, ABC.AccountCode 
ORDER BY ABC.ArbName, ABC.AccountCode
