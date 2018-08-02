DECLARE
      @DischargeOrderID       INT   = 151

/*
Declare
      @DischargeOrderID       int
SELECT
      @DischargeOrderID       = 3
*/
SELECT
      Doctors.Code																AS DoctorCode,
      Doctors.EngName															AS DoctorNameEng,
      Doctors.ArbName															AS DoctorNameArb,
      Patients.FileNum															AS MRN,
      Patients.EngName															AS MRNameEng,
      Patients.ArbName															AS MRNameArb,
      Patients.DOB,
      Patients.Sex,
	  A.AdmDate,
	  A.AdmTime,
	  (SELECT Code + ': ' + EngName FROM Doctors WHERE A.DoctorID = ID)			AS DoctorAdm,
	  CASE WHEN A.PayMethod = 'C' THEN 'CASH' ELSE 'CREDIT' END					AS PayMethod,
	  (SELECT Code + ': ' + EngName FROM Accounts WHERE A.AccountID = ID)		AS Account,
      DO.DischargeDate															AS MedicalDsgDate,
	  A.DsgDate,
      Do.DischargeTime															AS MedicalDsgTime,
	  A.DsgTime,
	  (SELECT TOP 1  I.Code + ': ' + I.EngName AS ServiceItem
		FROM AdmissionsPackages AP
			INNER JOIN ServiceItems I ON I.ID = AP.ServiceItemID 
			WHERE AP.AdmissionID = A.ID)										AS PackageOperation,
	  (SELECT TOP 1  TransHdr.RegDate AS ServiceItem
		FROM AdmissionsPackages AP
			INNER JOIN ServiceItems I ON I.ID = AP.ServiceItemID 
			INNER JOIN TransHdr ON TransHdr.AdmissionID = A.ID
			INNER JOIN TransDtl ON TransDtl.TransHdrID = TransHdr.ID 
				And I.ID = TransDtl.ServiceItemID 
			WHERE AP.AdmissionID = A.ID)										AS OperationDate,
	  (SELECT TOP 1 ICDs.Code + ': ' + ICDs.Description 
		FROM ICDs WHERE R.ICD1ID = ICDs.ID)										AS ReASonForAdmission,
	  Referal,
      ConditionAtDischarge,
      ConditionAtDischargeOthers,
	  SurgicalIntervention,
      OutcomeOfSurgery,
      StatusOfDischarge,
      FollowUpMedications,
      SpecialCare,
      PatientEducation,
      FollowUpVisit,
      ICDdiseASes.Code															AS ICDdiseASesCode,
      ICDdiseASes.Description													AS ICDdiseASesDescription,
      ICDProcedures.Code														AS ICDProceduresCode,
      ICDProcedures.Description													AS ICDProceduresDescription,
      ICDProcedures.Block														AS ICDProceduresBlock,
      DO.Remarks,
      DO.RegDate
      
FROM
      DischargeOrders DO
	  INNER JOIN  Admissions A					ON DO.AdmissionID		= A.ID
	  LEFT  JOIN  AdmissionsRecommendations R	ON R.AdmissionID		= A.ID
      INNER JOIN  Doctors						ON DO.DoctorID			= Doctors.ID
      INNER JOIN  Patients						ON DO.PatientID         = Patients.ID
      LEFT  JOIN  DischargeOrdersICDdiseASes	ON DO.ID				= DischargeOrdersICDdiseASes.DischargeOrderID
      LEFT  JOIN  ICDdiseASes					ON ICDdiseASeID         = ICDdiseASes.ID
      LEFT  JOIN  DischargeOrdersICDProcedures	ON DO.ID				= DischargeOrdersICDProcedures.DischargeOrderID
      LEFT  JOIN  ICDProcedures					ON ICDProceduresID      = ICDProcedures.ID
WHERE
	DO.ID	Like @DischargeOrderID
