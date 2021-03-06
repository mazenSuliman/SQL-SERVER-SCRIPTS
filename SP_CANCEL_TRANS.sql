USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_CANCEL_TRANS]    Script Date: 02/08/2018 11:21:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CANCEL_TRANS] 
		 @SYSTEMUSER	VARCHAR(50)			= '%'
		,@INOUT			VARCHAR(50)			= '%'
		,@FromDate		SMALLDATETIME		= '2000-01-01 00:00:00' 
		,@ToDate		SMALLDATETIME		= '2039-12-31 23:59:59'
AS
BEGIN
	SELECT DISTINCT	
		 U1.Code											AS CANCELUSERCODE
		,U1.EngName											AS CANCELUSER
		,U2.EngName											AS REGISTERUSER
		,CASE WHEN H.InOut = 'O' THEN 'Out' ELSE 'In' END	AS TYPEOFPATIENT
		,H.RegDate											AS REGDATE
		,H.CancelDate										AS CANCELDATE
		,ISNULL(H.GrossAmount, 0)							AS AMOUNT
		,H.TransNum											AS TRANSNUM
		,h.RespCenterCode                                   AS Resp_Center
		,H.Remarks		  
		,@FROMDATE											AS FROMDATE
		,@TODATE											AS TODATE

FROM	TransHdr H
			INNER JOIN	SystemUsers U1		ON H.CancelUserID	= U1.ID
			INNER JOIN	SystemUsers U2		ON H.RegUserID		= U2.ID

WHERE	H.TransDate BETWEEN @FROMDATE AND @TODATE
			AND U1.Code LIKE @SYSTEMUSER + '%'
			AND H.InOut = CASE WHEN @INOUT = '%' THEN H.InOut WHEN @INOUT = 'OUT' THEN 'O' ELSE 'I' END
			AND H.CancelDate IS NOT NULL
END
