USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_ADMISSION_DOCTORS]    Script Date: 02/08/2018 11:17:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[SP_ADMISSION_DOCTORS]
	@FileNum					int 			= 0,
	@Doctor						varchar(20) 	= '%',
	@FromDate					SMALLDATETIME	= '2007-01-01' ,
	@ToDate						SMALLDATETIME	= '2047-12-3'

AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT B.Code
			, A.ID
			, P.FileNum
			, P.EngName
			, CASE WHEN A.AccountCode = 'CASH' THEN 'CASH' 
				   WHEN A.AccountCode = 'MOH'	THEN 'MOH'
				   ELSE 'CREDIT' END AS ACCOUNTCODE
			, A.AdmDate
			, A.DsgDate
			, DCS.DOCTOR2
			, DCS.DOCCODE    AS DOCCODE
			, DSS.EngName AS SPECNAME
			,	DCS.ITEMCODE AS ITEMCODE
			,	DCS.SERVICENAME
			,	DCS.PRICE
			, @FromDate FROMDATE
			, @ToDate   TODATE
	FROM Admissions A
		JOIN AdmissionsDoctors D			ON A.ID = D.AdmissionID
		JOIN Doctors DC2					ON D.DoctorID = DC2.ID
		JOIN Patients P						ON A.PatientID = P.ID
		JOIN Beds B							ON B.ID = A.BedID
		JOIN (SELECT A.ID
		, DC2.EngName			AS DOCTOR2
		, DC2.Code				AS DOCCODE
		, DC2.DoctorSpecialtyID 
		, P.ServiceItemCode		AS ITEMCODE
		, I.EngName				AS SERVICENAME
		, P.ContractPrice		AS PRICE 
	FROM Admissions A
		JOIN AdmissionsDoctors D			ON A.ID = D.AdmissionID
		JOIN Doctors DC						ON A.DoctorID = DC.ID
		JOIN Doctors DC2					ON D.DoctorID = DC2.ID
		LEFT JOIN AdmissionsPackages P			ON A.ID = P.AdmissionID
		LEFT JOIN ServiceItems I					ON I.Code = P.ServiceItemCode) AS DCS ON DCS.ID = A.ID
		
		JOIN DoctorsSpecialties AS DSS ON DCS.DoctorSpecialtyID = DSS.ID
	WHERE A.AdmDate BETWEEN @FromDate AND @ToDate
	And	P.FileNum 		= Case When @FileNum <> 0 Then @FileNum Else P.FileNum  End
	And	DoctorCode 		Like @Doctor + '%'

	ORDER BY A.AdmDate
END
