SELECT * FROM TransHdr
--UPDATE TransHdr SET ConsultationTransHdrID = 1364817
WHERE ID IN
(SELECT ID FROM TransHdr H
WHERE 
	H.PatientFileNum = 582095
	AND H.TransDate BETWEEN '2018-07-17' AND '2018-07-19'
	--AND H.ConsultationTransHdrID = 1364770
	--AND H.ID <> 1364770
	--ConsultationTransHdrID = (SELECT ID FROM TransHdr WHERE ID = 200368)
	)