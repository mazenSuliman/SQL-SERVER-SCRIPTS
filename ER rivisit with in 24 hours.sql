SELECT	  P.FileNum
		, P.EngName
		, H1.RegDate
		, D1.Code
		, D1.EngName
		, H2.RegDate
		, D2.Code
		, D2.EngName

FROM TransHdr H1
JOIN TransHdr H2 ON H1.PatientID = H2.PatientID AND H1.ID != H2.ID
JOIN Doctors D1 ON H1.DoctorID = D1.ID
JOIN Doctors D2 ON H2.DoctorID = D2.ID
JOIN Patients P ON H1.PatientID = P.ID

WHERE
H1.CancelDate IS NULL
AND H2.CancelDate IS NULL
AND H1.TransDate BETWEEN '2018-01-01' AND '2018-12-31'
AND H1.IsConsultation = 1
AND H2.IsConsultation = 1
AND D1.DoctorSpecialtyID = 170
AND D2.DoctorSpecialtyID = 170
--AND H1.RespCenterCode LIKE '%GRP%'
--AND H2.RespCenterCode LIKE '%GRP%'
AND H2.RegDate BETWEEN H1.RegDate AND DATEADD(DAY, 1, H1.RegDate)
