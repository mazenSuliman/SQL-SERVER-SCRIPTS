USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_iTEMS_BY_CATEGORY_Freqancy]    Script Date: 02/08/2018 11:29:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_iTEMS_BY_CATEGORY_Freqancy] 
	@FROMDATE		SMALLDATETIME = '2007-01-01',
	@TODATE			SMALLDATETIME = '2047-12-31',
	@SERVICEITEM  Varchar(20)	= '%', 
	@SERVICEGROUP varchar(20)	= '%'
AS
BEGIN
	SELECT	 I.Code			ITEMCODE
			,I.EngName		ITEMENGNAME
			,I.ArbName		ITEMARBNAME
			,I.CashPrice	ITEMPRICE
			,C.Code			GROUPCODE
			,c.EngName		GROUPNAME
			,ISNULL(FREQ.FREQUANCY, 0) FREQUANCY
			,@FROMDATE		FROMDATE
			,@TODATE		TODATE

	FROM ServiceItems AS I
		INNER join ServiceGroups AS C ON I.ServiceGroupID = C.ID
		LEFT  JOIN (SELECT D.ServiceItemID, COUNT(D.ID) AS FREQUANCY 
					FROM TransDtl D 
						INNER JOIN TransHdr H ON D.TransHdrID = H.ID 
					WHERE H.CancelDate IS NULL 
						AND H.TransDate BETWEEN @FROMDATE AND @TODATE
					GROUP BY ServiceItemID) AS FREQ ON I.ID = FREQ.ServiceItemID
	WHERE I.CancelDate is null
		AND I.Code = CASE WHEN @SERVICEITEM		= '%' THEN I.Code ELSE @SERVICEITEM  END
		AND C.Code = CASE WHEN @SERVICEGROUP	= '%' THEN C.Code ELSE @SERVICEGROUP END
		AND FREQUANCY IS NOT NULL
	ORDER BY I.ServiceGroupID ;
END
