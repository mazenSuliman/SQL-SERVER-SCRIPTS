USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_iTEMS_BY_CATEGORY]    Script Date: 02/08/2018 11:29:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_iTEMS_BY_CATEGORY] 
	@SERVICEITEM  Varchar(20)	= '%', 
	@SERVICEGROUP varchar(20)	= '%',
	@SERVICECAT varchar(20)	= '%'
AS
BEGIN
	SELECT	 I.Code			ITEMCODE
			,I.EngName		ITEMENGNAME
			,I.ArbName		ITEMARBNAME
			,I.CashPrice	ITEMPRICE
			,C.Code			GROUPCODE
			,c.EngName		GROUPNAME

	FROM ServiceItems AS I 
		inner join ServiceGroups AS C ON I.ServiceGroupID = C.ID
		inner join ServiceItemsCats AS SIC on i.id =  SIC.ServiceItemID 
		INNER JOIN ServiceCats SC ON SC.ID = SIC.ServiceCatID
	WHERE I.CancelDate is null
		AND I.Code = CASE WHEN @SERVICEITEM		= '%' THEN I.Code ELSE @SERVICEITEM  END
		AND C.Code = CASE WHEN @SERVICEGROUP	= '%' THEN C.Code ELSE @SERVICEGROUP END
		AND sc.CODE = CASE WHEN @SERVICECAT	= '%' THEN sc.Code ELSE @SERVICECAT END
	ORDER BY I.ServiceGroupID ;
END
