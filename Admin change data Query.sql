SELECT * FROM Admissions
--UPDATE Admissions SET DsgDate = NULL, DsgTime = NULL, DsgUserID = NULL
--UPDATE Admissions SET AdmDate = DATEADD(DAY, 1, AdmDate), ExpDsgDateTime = DATEADD(DAY, 1, AdmDate)
WHERE PatientID = (SELECT ID FROM Patients WHERE FileNum = 312450)