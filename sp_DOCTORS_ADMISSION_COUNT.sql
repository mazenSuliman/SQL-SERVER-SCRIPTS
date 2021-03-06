USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCTORS_ADMISSION_COUNT]    Script Date: 02/08/2018 11:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[sp_DOCTORS_ADMISSION_COUNT]
	@DOCTORID					VARCHAR = '%',
	@SPECIALITY					int = 0,
	@FromDate					SMALLDATETIME = '2000-01-01' ,
	@ToDate						SMALLDATETIME = '2059-12-31'

As

SELECT   DOCTORS.Code						AS CODE
		,Doctors.EngName					AS DOCTORNAME
		,Doctors.DoctorSpecialtyID			AS SPEC
		,[DoctorsSpecialties].EngName		AS SpecName
		,ISNULL( A1.QTY, 0)					AS CASH
		,ISNULL( A2.QTY, 0)					AS MOH
		,ISNULL( A3.QTY, 0)					AS CREDIT
		,@FromDate							AS fromdate
		,@ToDate							AS todate

FROM
	ALDar_Hospital.dbo.Doctors
	LEFT join 
	(
		SELECT AR.DoctorID 
			,COUNT(*) AS QTY
		FROM AdmissionsRecommendations	AS AR
			INNER JOIN Admissions		AS A	ON AR.AdmissionID = A.ID
		WHERE A.AccountCode = 'CASH'
				AND A.AdmDate BETWEEN @FromDate AND @ToDate
		GROUP BY AR.DoctorID) AS A1 on Doctors.id = A1.DoctorID

	 FULL JOIN(
		SELECT AR.DoctorID 
			,COUNT(*) AS QTY
		FROM AdmissionsRecommendations	AS AR
			INNER JOIN Admissions		AS A	ON AR.AdmissionID = A.ID
		WHERE A.AccountCode = 'MOH'
				AND A.AdmDate BETWEEN @FromDate AND @ToDate
		GROUP BY AR.DoctorID) AS A2 ON Doctors.id = A2.DoctorID

	 FULL JOIN(
		SELECT AR.DoctorID 
			,COUNT(*) AS QTY
		FROM AdmissionsRecommendations	AS AR
			INNER JOIN Admissions		AS A	ON AR.AdmissionID = A.ID
		WHERE A.AccountCode NOT IN  ('CASH','MOH')
				AND A.AdmDate BETWEEN @FromDate AND @ToDate
		GROUP BY AR.DoctorID) AS A3 ON Doctors.id = A3.DoctorID

	  LEFT JOIN [ALDar_Hospital].[dbo].[DoctorsSpecialties]	ON DoctorSpecialtyID = [ALDar_Hospital].[dbo].[DoctorsSpecialties].[ID]

where 
		A1.QTY is not null
	AND A2.QTY is not null
	AND A3.QTY is not null
	AND DOCTORS.Code = @DOCTORID + '%'
	AND DoctorSpecialtyID = CASE WHEN @SPECIALITY = 0 THEN DoctorSpecialtyID ELSE @SPECIALITY END


