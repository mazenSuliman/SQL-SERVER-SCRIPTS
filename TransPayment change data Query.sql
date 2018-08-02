SELECT * FROM TransPayments
--SELECT * FROM TransPaymentsDtl
--UPDATE TransPayments SET TransDate = DATEADD(DAY, 6, TransDate), RegDate = DATEADD(DAY, 4, RegDate)
WHERE ID IN (SELECT ID 
			 FROM TransPayments P
			 WHERE P.PatientID = (SELECT ID FROM Patients WHERE FileNum = 584526) 
				 AND Amount < 0)