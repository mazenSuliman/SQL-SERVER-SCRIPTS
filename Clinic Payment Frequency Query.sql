DECLARE
	 @FromDate			smalldatetime	= '2018-05-01'
	,@ToDate			smalldatetime	= '2018-05-31'
	,@FromTime			VARCHAR(50)     =	'00:00'
	,@ToTime			VARCHAR(50)     =	'23:59'
	,@DoctorCode		varchar(20)		= ''
	,@Specialty			varchar(20)		= ''
	,@AccountCode		varchar(20)		= ''



	SELECT   DocSpecialtyCode																					AS Specialty
			,MAX(DocSpecialtyName)																				AS SpecialtyName
			,DoctorCode																							AS Doctor 
			,SUM(ABC.MOH)																						AS 'صحة'
			,SUM(ABC.CASH)																						AS 'نقدي'
			,SUM(ABC.CREDIT)																					AS 'آجل'
			,MAX(DoctorName)																					AS DoctorName
			,MAX(TypeName)																						AS TypeName
			,MAX(RANKING)																						AS RANKING
			,@FromDate																							AS FROMDATE
			,@FROMTIME																							AS FROMTIME
			,@ToDate																							AS TODATE
			,@TOTIME																							AS TOTIME
			

	FROM
			(SELECT  TransHdr.ID ,
						DoctorsSpecialties.Code																	AS DocSpecialtyCode ,
						DoctorsSpecialties.ArbName																AS DocSpecialtyName ,
						ISNULL(DoctorsTypes.Remarks, 70)														AS RANKING,
						DoctorCode																				AS DoctorCode ,
						Doctors.ArbName																			AS DoctorName ,
						DoctorsTypes.ArbName																	AS TypeName,
						IsConsultation ,

						CASE WHEN AM.EngName = 'MOH' THEN 1 ELSE 0 END MOH,  
						CASE WHEN AM.EngName = 'CASH'  THEN 1 ELSE 0 END CASH,
						CASE WHEN AM.EngName <> 'MOH' AND AM.EngName <> 'CASH' THEN 1 ELSE 0 END AS CREDIT	
						--CASE WHEN PayMethod = 'R' AND AM.EngName = 'MOH' THEN 'صحة' WHEN PayMethod = 'C'  THEN 'نقدي' WHEN PayMethod = 'R' AND AM.EngName <> 'MOH' THEN 'آجل' END AS PayMethod						

			  FROM      Doctors	
						LEFT OUTER JOIN TransHdr					ON DoctorID							= Doctors.ID
						LEFT OUTER JOIN RespCenters					ON Doctors.RespCenterID				= RespCenters.ID
						LEFT OUTER JOIN DoctorsSpecialties			ON DoctorSpecialtyID				= DoctorsSpecialties.ID
						LEFT OUTER JOIN DoctorsTypes				ON LEFT(DoctorsTypes.EngName, 1)	= Doctors.DoctorType
						INNER JOIN	Accounts						ON TransHdr.AccountID				= Accounts.ID
						INNER JOIN AccountsContracts AC				ON AC.AccountID						= Accounts.ID
						INNER JOIN AccountsMain		AM				ON AC.AccountMainID					= AM.ID


			  WHERE     ISNULL(TransHdr.CancelDate, 0) = 0
						AND CAST(TransHdr.TransDate AS datetime)  BETWEEN @FromDate AND @ToDate
						AND RIGHT('00' + CAST(Datepart(hour ,TransHdr.RegDate) AS varchar) ,2)+ ':' + RIGHT( '00' + CAST(DATEPART(minute,TransHdr.RegDate) AS varchar)  ,2) BETWEEN @FromTime AND @ToTime
						AND Doctors.Code							LIKE	@DoctorCode		+ '%'
						AND DoctorsSpecialties.Code					LIKE	@Specialty		+ '%'
						AND AccountCode								LIKE	@AccountCode	+ '%'
						AND InOut									= 'O'
						AND TransHdr.IsConsultation = 1
	) AS ABC

	GROUP BY ABC.DocSpecialtyCode, DoctorCode

	--HAVING  COUNT(CASE WHEN IsConsultation	= 1 AND ISNULL(IsFreeRevisit, 0) <> 1	THEN ABC.ID				END)>0
	--	OR  COUNT(CASE WHEN IsFreeRevisit	= 1										THEN ABC.ID ELSE NULL	END)>0

	ORDER BY ABC.DocSpecialtyCode, DoctorCode