USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[SP_REC_DAILY]    Script Date: 02/08/2018 11:33:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_REC_DAILY] 
	 @USER		VARCHAR(20)		= '%'
	,@FROMDATE	SMALLDATETIME	= '2007-05-01'
	,@TODATE	SMALLDATETIME	= '2107-05-01'
	,@FROMTIME  TIME			= '00:00AM'
	,@TOTIME	TIME			= '11:59PM'
AS

BEGIN
	SELECT DISTINCT H.RegUserCode
		,U.EngName			AS USERNAME
		,G.EngName			AS GROUPNAME
		,ISNULL(M1.C, 0)	AS CON
		,ISNULL(M3.C, 0)	AS FOL
		,ISNULL(M2.C, 0)	AS SER
		,@FROMDATE			AS fromDate
		,@TODATE			AS toDate
		,@FROMTIME			AS fromTime
		,@TOTIME			AS toTime

	FROM TransHdr AS H

		LEFT OUTER JOIN (
			SELECT  RegUserCode, COUNT(*) AS C
			FROM TransHdr AS H
				INNER JOIN TransDtl AS D ON D.TransHdrID = H.ID
			WHERE RegDate BETWEEN @FROMDATE+@FROMTIME AND @TODATE+@TOTIME
				AND D.ServiceGroupID = 105
				AND H.IsConsultation = 1
			GROUP BY H.RegUserCode) AS M1 ON H.RegUserCode = M1.RegUserCode

		LEFT OUTER JOIN (
			SELECT  RegUserCode, COUNT(*) AS C
			FROM TransHdr AS H
				INNER JOIN TransDtl AS D ON D.TransHdrID = H.ID
			WHERE RegDate BETWEEN @FROMDATE+@FROMTIME AND @TODATE+@TOTIME
				AND D.ServiceGroupID = 105
				AND H.IsFreeRevisit = 1
			GROUP BY H.RegUserCode) AS M3 ON H.RegUserCode = M3.RegUserCode

		LEFT OUTER JOIN (
			SELECT  RegUserCode, COUNT(*) AS C
			FROM TransHdr AS H
				INNER JOIN TransDtl AS D ON D.TransHdrID = H.ID
			WHERE RegDate BETWEEN @FROMDATE+@FROMTIME AND @TODATE+@TOTIME
				AND H.IsConsultation = 0 
				AND H.IsFreeRevisit  IS NULL
			GROUP BY H.RegUserCode) AS M2 ON H.RegUserCode = M2.RegUserCode

		INNER JOIN SystemUsers			AS U	ON H.RegUserCode = U.Code
		INNER JOIN SystemGroupsUsers	AS GU	ON GU.SystemUserID = U.ID
		INNER JOIN SystemGroups			AS G	ON GU.SystemGroupID = G.ID

	WHERE GU.SystemGroupID IN (5, 11)
		AND H.RegUserCode LIKE @USER + '%'

	ORDER BY H.RegUserCode
END