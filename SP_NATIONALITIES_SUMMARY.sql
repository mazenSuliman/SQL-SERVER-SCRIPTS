USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_NATIONALITIES_SUMMARY]    Script Date: 02/08/2018 11:31:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_NATIONALITIES_SUMMARY]
	 @FROMDATE	SMALLDATETIME = '2000-01-01'
	,@TODATE	SMALLDATETIME = '2100-12-31'
AS
BEGIN
		(SELECT ISNULL(N.EngName, '--UNDEFINED--') ENGNAME
			,COUNT(DISTINCT H.PatientFileNum)
			,SUM(H.GrossAmount)
			,'CASH' AS PAYMENT
			,@FROMDATE  FROMDATE
			,@TODATE	TODATE
		FROM TransHdr H
			LEFT JOIN Patients P ON H.PatientID = P.ID
			LEFT JOIN Nationalities N ON P.NationalityID = N.ID
		WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE AND H.CancelDate IS NULL AND AccountCode = 'CASH'
		GROUP BY N.EngName)
	UNION 
		(SELECT ISNULL(N.EngName, '--UNDEFINED--') ENGNAME
			,COUNT(DISTINCT H.PatientFileNum)
			,SUM(H.GrossAmount)
			,'CREDIT' AS PAYMENT
			,@FROMDATE  FROMDATE
			,@TODATE	TODATE
		FROM TransHdr H
			LEFT JOIN Patients P ON H.PatientID = P.ID
			LEFT JOIN Nationalities N ON P.NationalityID = N.ID
		WHERE H.TransDate BETWEEN @FROMDATE AND @TODATE AND H.CancelDate IS NULL AND AccountCode <> 'CASH'
		GROUP BY N.EngName)
END
