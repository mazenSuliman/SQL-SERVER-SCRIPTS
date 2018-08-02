SELECT * FROM TransDtl
--UPDATE TransDtl SET CompanyVat = 500
WHERE ID IN
(SELECT D.ID
FROM TransDtl D
	JOIN TransHdr H ON D.TransHdrID = H.ID
WHERE 
	H.TransNum = 473822 AND H.TransYear = 2018)