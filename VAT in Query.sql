DECLARE
	 @MAINACCOUNT VARCHAR(50) = '65'
	,@FROMDATE	SMALLDATETIME = '2017-10-01'
	,@TODATE	SMALLDATETIME = '2017-10-31'


SELECT P.FileNum 
		,P.EngName
		,(CASE WHEN P.NationalityID = 158 THEN 'SAUDI' ELSE 'OTHERS' END) AS NAT
		,AC.EngName ACCOUNTNAME
		,AM.EngName MAINACCOUNT
		,A.AdmDate
		,A.DsgDate
		,I.InvoiceNum
		,I.InOut
		,(CASE WHEN A.PayMethod = 'C' THEN 'CASH' ELSE 'CREDIT' END) PayMethod
		,I.GrossAmount + I.GrossAmountPackage GROSS
		,I.DiscAmount + I.DiscAmountPackage + I.DiscAmountPackageFormal + I.OtherDiscAmount + I.OtherDiscAmountPackage DISCOUNT
		,I.DeductAmount + I.OtherDeductAmount + I.OutDeductAmount DeductAmount 
		,I.PatientVat
		,(I.GrossAmount + I.GrossAmountPackage) - (I.DiscAmount + I.DiscAmountPackage + I.DiscAmountPackageFormal + I.OtherDiscAmount + I.OtherDiscAmountPackage + I.DeductAmount + I.OtherDeductAmount + I.OutDeductAmount) NET
		, I.CompanyVat
		,(I.GrossAmount + I.GrossAmountPackage) - ((I.DiscAmount + I.DiscAmountPackage + I.DiscAmountPackageFormal + I.OtherDiscAmount + I.OtherDiscAmountPackage + I.DeductAmount + I.OtherDeductAmount + I.OutDeductAmount)) + (I.CompanyVat) CNET
	
FROM Invoices I
	JOIN Patients P ON I.PatientID = P.ID
	JOIN Admissions A ON I.AdmissionID = A.ID
	JOIN Accounts AC ON A.AccountID = AC.ID
	JOIN AccountsContracts ACC ON ACC.AccountID = AC.ID
	JOIN AccountsMain AM ON ACC.AccountMainID = AM.ID

WHERE I.CancelDate IS NULL
	AND A.DsgDate BETWEEN @FROMDATE AND @TODATE
	AND AM.Code = CASE WHEN @MAINACCOUNT = '' THEN AM.Code ELSE @MAINACCOUNT END
	--AND P.FileNum =  559915

ORDER BY A.AdmDate, AC.EngName, P.FileNum