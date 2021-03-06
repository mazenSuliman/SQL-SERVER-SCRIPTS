USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_LAB_TAT_DAYS_AVG]    Script Date: 02/08/2018 11:31:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_LAB_TAT_DAYS_AVG]
		@FromDate					DATETIME	= '2017-10-15 00:00:00' ,
		@ToDate						DATETIME	= '2017-10-15 23:59:59' ,
		@SERVICECAT					varchar(40)		= '%',
		@SERVICEITEM				varchar(40)		= '%'
AS
BEGIN
	
	SELECT	 DISTINCT I.Code		AS SERV
			, I.EngName				AS SERV_NAME
			, SC.EngName			AS CAT
			, AVER.AVG_IN_DAYS
			, @FROMDATE				AS FROMDATE
			, @TODATE				AS TODATE
		

	FROM	TransDtlCustomFormsSpecimens			AS SP 						
			INNER JOIN TransDtl 						AS D						ON SP.TransDtlsID 			= D.ID
			INNER JOIN TransHdr							AS H						ON D.TransHdrID 			= H.ID
			INNER JOIN ServiceItems						AS I						ON D.ServiceItemID 			= I.ID
			INNER JOIN ServiceItemsCats					AS C						ON C.ServiceItemID 			= I.ID
			INNER JOIN ServiceCats						AS SC						ON C.ServiceCatID 			= SC.ID
			INNER JOIN 
			(SELECT	 I.Code, AVG(1.0*ISNULL(DATEDIFF(MINUTE, SP.REGDATE, SP.CONFIRMDATE),0)/60/24) AS AVG_IN_DAYS
			FROM	TransDtlCustomFormsSpecimens			AS SP 						
				INNER JOIN TransDtl 						AS D						ON SP.TransDtlsID 			= D.ID
				INNER JOIN TransHdr							AS H						ON D.TransHdrID 			= H.ID
				INNER JOIN ServiceItems						AS I						ON D.ServiceItemID 			= I.ID
			WHERE	H.CancelDate Is Null
				AND I.ServiceGroupID = 26
				And	SP.ConfirmDate			Between @FromDate + '00:00:00' And @ToDate + '23:59:59'
			GROUP BY I.Code) AS AVER ON AVER.Code = I.Code

	WHERE SC.Code						Like @ServiceCat	+ '%'
			AND I.CODE						LIKE @SERVICEITEM	+ '%'
END
