USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_OUT_SPECIMENTS]    Script Date: 02/08/2018 11:32:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_OUT_SPECIMENTS]
		 @FromDate					SMALLDATETIME	= '2000-01-01'
		,@FromTime     varchar(50)     ='00:00'
		,@ToDate					SMALLDATETIME	= '2100-12-31'
		,@ToTime       varchar(50)     ='23:59'
		,@MRN			VARCHAR(50)		= '%'
		,@LABNUM			VARCHAR(50)		= '%'
		,@SpecimenNumber	VARCHAR(50)		= '%'
		,@SERVICEITEM		VARCHAR(50)		= '%'
AS
BEGIN
	SELECT	 P.EngName				AS Patient_Name
			,P.FileNum				AS Medical
			,T.LabNumber			AS Lab
			,T.SpecimenNumber		AS SPECNUM
			,CONVERT(varchar, YEAR(GETDATE()) - YEAR(P.DOB)) + 'Y' AGE
			,P.Sex
			,I.EngName				AS Required_Tests
			,'Not Available'	Remarks
			,T.SpecimenDate
			,@FromDate				AS FROMDATE
			,@ToDate				AS TODATE

	FROM	TransHdr H 
			JOIN TransDtl D ON D.TransHdrID = H.ID
			JOIN TransDtlCustomFormsSpecimens T ON T.TransDtlsID = D.ID
			JOIN ServiceItems I ON D.ServiceItemCode = I.Code
			JOIN ServiceItemsCats IC ON IC.ServiceItemID = I.ID
			JOIN Patients P ON H.PatientID = P.ID

	WHERE I.ServiceGroupID = 26
		AND I.CancelDate IS NULL
		--AND I.SECCode IS NOT NULL
		AND IC.ServiceCatID IN (116, 107)

		AND H.CancelDate IS NULL
		AND T.SpecimenDate BETWEEN @FromDate + @FromTime AND @ToDate + @ToTime
		AND P.FileNum LIKE @MRN + '%'
		AND T.LabNumber LIKE @LABNUM + '%'
		AND I.Code LIKE @SERVICEITEM + '%'
		AND T.SpecimenNumber LIKE @SpecimenNumber + '%'

END
