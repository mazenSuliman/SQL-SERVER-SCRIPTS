USE [ALDar_Hospital]
GO
/****** Object:  StoredProcedure [dbo].[sp_DOCTORS_XRAY_INCOME]    Script Date: 02/08/2018 11:27:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[sp_DOCTORS_XRAY_INCOME]
	@SPECIALITY					varchar(20)			= '%',
	@FromDate					SMALLDATETIME		= '01/01/2000' ,
	@ToDate						SMALLDATETIME		= '31/12/2059'

As

SELECT DISTINCT  D.EngName							AS Name
				, D.DoctorSpecialtyID				AS Spec
				, CASt (d.Code AS varchar(20))		AS code
				, [DoctorsSpecialties].EngName		AS SpecName
				, ISNULL(Ultrasound.Price, 0)		AS Ultrasound
				, ISNULL(Ultrasound.Qty, 0)			AS UltrasoundQty
				, ISNULL(Xray.Price, 0)				AS Xray
				, ISNULL(Xray.Qty, 0)				AS XrayQty
				, ISNULL(CTScan.Price, 0)			AS CTScan
				, ISNULL(CTScan.Qty, 0)				AS CTScanQty
				, ISNULL(MRI.Price, 0)				AS MRI
				, ISNULL(MRI.Qty, 0)				AS MRIQty
				, @FromDate							AS fromdate
				, @ToDate							AS todate
				
				
FROM [ALDar_Hospital].[dbo].Doctors AS D 
 
LEFT JOIN (
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(TransDtl.ID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
	Where TransDtl.ServiceGroupID = 25
		AND  [TransHdr].TransDate between @FromDate and @ToDate
	Group by [DoctorCode])
AS Ultrasound ON D.Code = Ultrasound.[DoctorCode]

LEFT JOIN ( 
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(TransDtl.ID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
	Where TransDtl.ServiceGroupID = 24
		AND  [TransHdr].TransDate between @FromDate and @ToDate
	Group by [DoctorCode])
AS Xray ON D.Code = Xray.[DoctorCode]

LEFT JOIN ( 
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(TransDtl.ID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
	Where TransDtl.ServiceGroupID = 30
		AND  [TransHdr].TransDate between @FromDate and @ToDate
	Group by [DoctorCode])
AS CTScan ON D.Code = CTScan.[DoctorCode]

LEFT JOIN(
  Select  [DoctorCode]
		, SUM(TransDtl.ContractPrice) As Price
		, COUNT(TransDtl.ID) As Qty
	From TransHdr 
		join TransDtl on TransDtl.TransHdrID = TransHdr.ID
	Where TransDtl.ServiceGroupID = 31
		AND  [TransHdr].TransDate between @FromDate and @ToDate
	Group by [DoctorCode])  
AS MRI ON D.Code = MRI.[DoctorCode]

LEFT JOIN [ALDar_Hospital].[dbo].[TransHdr] ON D.Code = [ALDar_Hospital].[dbo].[TransHdr].[DoctorCode]
LEFT JOIN [ALDar_Hospital].[dbo].[DoctorsSpecialties] ON D.DoctorSpecialtyID = [ALDar_Hospital].[dbo].[DoctorsSpecialties].[ID]

where [ALDar_Hospital].[dbo].[DoctorsSpecialties].Code = CASE WHEN @SPECIALITY = '%' THEN [ALDar_Hospital].[dbo].[DoctorsSpecialties].Code ELSE @SPECIALITY END


