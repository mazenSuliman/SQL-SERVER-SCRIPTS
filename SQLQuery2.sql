DECLARE
	 @FromDate			smalldatetime	= '2017-05-01'
	,@ToDate			smalldatetime	= '2017-12-31'
	,@FromTime			VARCHAR(50)     =	'00:00'
	,@ToTime			VARCHAR(50)     =	'23:59'
	,@DoctorCode		varchar(20)		= ''
	,@Specialty			varchar(20)		= ''
	,@AccountCode		varchar(20)		= ''
	,@PayMethod			varchar(1)		= '%'


BEGIN
	DECLARE @TotalSum MONEY;
	
	SELECT  @TotalSum = ( SELECT    SUM(ISNULL(GrossAmount,				0)
										- ISNULL(FractionAmount,		0)
										- ISNULL(DiscountAmount,		0)
										- ISNULL(OtherDiscountAmount,	0)
										- ISNULL(InvoiceOtherDiscount,	0))

						  FROM      TransHdr
									LEFT OUTER JOIN Doctors				ON DoctorID				= Doctors.ID
									LEFT OUTER JOIN DoctorsSpecialties	ON DoctorSpecialtyID	= DoctorsSpecialties.ID

						  WHERE     ISNULL(TransHdr.CancelDate, 0) = 0
									AND TransDate						BETWEEN @FromDate		AND @ToDate
									AND Doctors.Code					LIKE	@DoctorCode		+ '%'
									AND DoctorsSpecialties.Code			LIKE	@Specialty		+ '%'
									AND AccountCode						LIKE	@AccountCode	+ '%'
									AND InOut							=		'O'
									AND PayMethod						LIKE	@PayMethod
						);


					
	SELECT   DocSpecialtyCode																					AS Specialty
			,MAX(DocSpecialtyName)																				AS SpecialtyName
			--,DoctorCode																							AS Doctor 
			,MAX(PayMethod)																					AS DoctorName
			--,MAX(TypeName)																						AS TypeName
			--,MAX(RANKING)																						AS RANKING
			,COUNT(Case When IsNull(IsConsultation, 0) = 1 And IsNull(IsFreeRevisit, 0) = 0  THEN  ABC.ID END)			AS NoCons
			--,SUM(ConsAmount)																					AS ConsAmount
			,COUNT(CASE WHEN  IsNull(IsConsultation, 0) = 1 And IsNull(IsFreeRevisit, 0) = 1 THEN ABC.ID END)										AS NoRevisits
			--,SUM(ClinicService)																					AS ClinicServices
			--,SUM(Lab)																							AS Lab
			--,SUM(XRay)																							AS XRay
			--,SUM(Pharmacy)																						AS Pharmacy
			--,SUM(TotalCash)																						AS TotalOut
			,SUM(Total)																							AS Total
			--,SUM(Total) * 100 / @TotalSum																		AS IncomePercent
			--,@FromDate																							AS FROMDATE
			--,@FROMTIME																							AS FROMTIME
			--,@ToDate																							AS TODATE
			--,@TOTIME																							AS TOTIME
			

	FROM
			(SELECT  TransHdr.ID ,
						DoctorsSpecialties.Code																	AS DocSpecialtyCode ,
						DoctorsSpecialties.ArbName																AS DocSpecialtyName ,
						ISNULL(DoctorsTypes.Remarks, 70)														AS RANKING,
						DoctorCode																				AS DoctorCode ,
						Doctors.ArbName																			AS DoctorName ,
						DoctorsTypes.ArbName																	AS TypeName,
						CASE WHEN PayMethod = 'R' AND AM.EngName = 'MOH' THEN 'صحة' WHEN PayMethod = 'C'  THEN 'نقدي' WHEN PayMethod = 'R' AND AM.EngName <> 'MOH' THEN 'آجل' END AS PayMethod,
						IsConsultation ,
						IsFreeRevisit ,

						CASE WHEN IsConsultation = 1 AND ISNULL(IsFreeRevisit, 0) <> 1
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS ConsAmount ,

						CASE WHEN PATINDEX('%' + ISNULL(RespCenters.RespCenterType, 'O') + '%', 'XLP') = 0
								  AND ISNULL(IsConsultation, 0) <> 1
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS ClinicService ,

						CASE WHEN RespCenters.RespCenterType = 'X'
							 THEN ISNULL(GrossAmount, 0) - ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS XRay ,

						CASE WHEN RespCenters.RespCenterType = 'L'
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS Lab ,

						CASE WHEN RespCenters.RespCenterType = 'P'
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS Pharmacy ,

						CASE WHEN TRANSHDR.PayMethod = 'C'
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS TotalCash ,

						CASE WHEN TRANSHDR.PayMethod = 'R'
							 THEN ISNULL(GrossAmount, 0) 
									- ISNULL(FractionAmount, 0)
									- ISNULL(DiscountAmount, 0)
									- ISNULL(OtherDiscountAmount, 0)
									- ISNULL(InvoiceOtherDiscount, 0)
							 ELSE 0 END																			AS TotalCredit ,

						ISNULL(GrossAmount, 0) 
							- ISNULL(FractionAmount, 0)
							- ISNULL(DiscountAmount, 0) 
							- ISNULL(OtherDiscountAmount, 0)
							- ISNULL(InvoiceOtherDiscount, 0)														AS Total

			  FROM      Doctors	
						LEFT OUTER JOIN TransHdr					ON DoctorID							= Doctors.ID
						LEFT OUTER JOIN RespCenters					ON Doctors.RespCenterID				= RespCenters.ID
						LEFT OUTER JOIN DoctorsSpecialties			ON DoctorSpecialtyID				= DoctorsSpecialties.ID
						LEFT OUTER JOIN DoctorsTypes				ON LEFT(DoctorsTypes.EngName, 1)	= Doctors.DoctorType
						Inner Join	Accounts		On TransHdr.AccountID  = Accounts.ID
						INNER JOIN AccountsContracts AC ON AC.AccountID = Accounts.ID
						INNER JOIN AccountsMain		AM ON AC.AccountMainID = AM.ID
			  WHERE     ISNULL(TransHdr.CancelDate, 0) = 0
						AND CAST(TransHdr.TransDate AS datetime)  BETWEEN @FromDate AND @ToDate
						AND RIGHT('00' + CAST(Datepart(hour ,TransHdr.RegDate) AS varchar) ,2)+ ':' + RIGHT( '00' + CAST(DATEPART(minute,TransHdr.RegDate) AS varchar)  ,2) BETWEEN @FromTime AND @ToTime
						AND Doctors.Code							LIKE	@DoctorCode		+ '%'
						AND DoctorsSpecialties.Code					LIKE	@Specialty		+ '%'
						AND AccountCode								LIKE	@AccountCode	+ '%'
						AND InOut									= 'O'
						AND TRANSHDR.PayMethod								LIKE	@PayMethod		+ '%'
	) AS ABC

	GROUP BY ABC.DocSpecialtyCode, ABC.PayMethod

	--HAVING  COUNT(CASE WHEN IsConsultation	= 1 AND ISNULL(IsFreeRevisit, 0) <> 1	THEN ABC.ID				END)>0
	--	OR  COUNT(CASE WHEN IsFreeRevisit	= 1										THEN ABC.ID ELSE NULL	END)>0

	ORDER BY ABC.DocSpecialtyCode, ABC.PayMethod
END
