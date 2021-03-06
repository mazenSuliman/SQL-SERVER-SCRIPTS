USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_LAB_STATISTICS_01]    Script Date: 02/08/2018 11:30:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_LAB_STATISTICS_01] 
				 @SERVICECAT									VARCHAR(50)		= '%'
				,@SERVICEITEM									VARCHAR(50)		= '%'
				,@FROMDATE										SMALLDATETIME	= '2007-01-01'
				,@TODATE										SMALLDATETIME	= '2047-12-31'
AS
BEGIN
	SET NOCOUNT ON;
	SELECT DISTINCT  D.ServiceItemCode								AS ITEM_CODE
				,I.EngName										AS ITEM_NAME
				,C.Code											AS CAT_CODE
				,C.EngName										AS CAT_NAME
				,ISNULL(CASH.COUNTING, 0)						AS CASH_C
				,ISNULL(CASH.BASIC_PRICE, 0)					AS CASH_BASIC
				,ISNULL(CASH.NET_PRICE, 0)						AS CASH_NET
				,ISNULL(MOH.COUNTING, 0)						AS MOH_C
				,ISNULL(MOH.BASIC_PRICE, 0)						AS MOH_BASIC
				,ISNULL(MOH.NET_PRICE, 0)						AS MOH_NET
				,ISNULL(CREDIT.COUNTING, 0)						AS CREDIT_C
				,ISNULL(CREDIT.BASIC_PRICE, 0)					AS CREDIT_BASIC
				,ISNULL(CREDIT.NET_PRICE, 0)					AS CREDIT_NET
				,ISNULL(TOTALS.COUNTING, 0)						AS TOTALS_C
				,ISNULL(TOTALS.BASIC_PRICE, 0)					AS TOTALS_BASIC
				,ISNULL(TOTALS.NET_PRICE, 0)					AS TOTALS_NET
				,@FROMDATE										AS FROMDATE
				,@TODATE										AS TODATE

FROM TransDtl D
				JOIN ServiceItems I 							ON D.ServiceItemID = I.ID
				JOIN TransHdr H 								ON D.TransHdrID = H.ID
				JOIN ServiceItemsCats IC 						ON IC.ServiceItemID = I.ID
				JOIN ServiceCats C 								ON IC.ServiceCatID = C.ID

LEFT JOIN (			
			SELECT 
				 D.ServiceItemCode								AS CODE
				,COUNT(D.ID)									AS COUNTING
				,SUM(D.BasicPrice)								AS BASIC_PRICE
				,SUM(D.ContractPrice)							AS NET_PRICE

			FROM TransDtl D
				JOIN TransHdr H 								ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens S 			ON S.TransDtlsID = D.ID

			WHERE
				H.CancelDate IS NULL
				AND D.ServiceGroupCode = '26'
				AND H.PayMethod = 'C'
				--AND H.AccountCode = 'MOH'
				AND S.RegDate IS NOT NULL
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE

			GROUP BY D.ServiceItemCode) 

AS CASH ON CASH.CODE = D.ServiceItemCode

LEFT JOIN (			
			SELECT 
					D.ServiceItemCode							AS CODE
				,COUNT(D.ID)									AS COUNTING
				,SUM(D.BasicPrice)								AS BASIC_PRICE
				,SUM(D.ContractPrice)							AS NET_PRICE

			FROM TransDtl D
				JOIN TransHdr H 								ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens S 			ON S.TransDtlsID = D.ID

			WHERE
				H.CancelDate IS NULL
				AND D.ServiceGroupCode = '26'
				AND H.PayMethod = 'R'
				AND H.AccountCode = 'MOH'
				AND S.RegDate IS NOT NULL
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE

			GROUP BY D.ServiceItemCode)

AS MOH ON MOH.CODE = D.ServiceItemCode

LEFT JOIN (			
			SELECT 
				 D.ServiceItemCode								AS CODE
				,COUNT(D.ID)									AS COUNTING
				,SUM(D.BasicPrice)								AS BASIC_PRICE
				,SUM(D.ContractPrice)							AS NET_PRICE

			FROM TransDtl D
				JOIN TransHdr H 								ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens S 			ON S.TransDtlsID = D.ID

			WHERE
				H.CancelDate IS NULL
				AND D.ServiceGroupCode = '26'
				AND H.PayMethod = 'R'
				AND H.AccountCode <> 'MOH'
				AND S.RegDate IS NOT NULL
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE

			GROUP BY D.ServiceItemCode) 

AS CREDIT ON CREDIT.CODE = D.ServiceItemCode

LEFT JOIN (			
			SELECT  
				 D.ServiceItemCode								AS CODE
				,COUNT(D.ID)									AS COUNTING
				,SUM(D.BasicPrice)								AS BASIC_PRICE
				,SUM(D.ContractPrice)							AS NET_PRICE

			FROM TransDtl D
				JOIN TransHdr H 								ON D.TransHdrID = H.ID
				JOIN TransDtlCustomFormsSpecimens S 			ON S.TransDtlsID = D.ID

			WHERE
				H.CancelDate IS NULL
				AND D.ServiceGroupCode = '26'
				AND S.RegDate IS NOT NULL
				AND H.TransDate BETWEEN @FROMDATE AND @TODATE

			GROUP BY D.ServiceItemCode) 

AS TOTALS ON TOTALS.CODE = D.ServiceItemCode

WHERE		D.ServiceGroupCode = '26'
		AND I.Code LIKE @SERVICEITEM + '%'
		AND C.Code LIKE @SERVICECAT  + '%'
END
