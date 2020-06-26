IF OBJECT_ID('tempdb..#tttt') IS NOT NULL DROP TABLE #tttt
SELECT DISTINCT D.dealnum, DLY.claimdly_sid, CR.claim_sid
INTO #tttt
FROM ERMS.dbo.tbl_deals AS D
INNER JOIN ERMS.dbo.tb_deals AS DD ON D.dealnum = DD.dealnum
INNER JOIN ERMS.dbo.tbl_claim_dly AS DLY ON D.dealnum = DLY.dealnum
INNER JOIN ERMS.dbo.tb_claim CR on CR.claim_sid = DLY.claim_rsid
INNER JOIN ERMS.dbo.tb_deallayeryr LY on LY.dealnum = DLY.dealnum and LY.layer = DLY.layer and LY.yearnum = DLY.yearnum
LEFT JOIN ERMS.dbo.tb_claim_events AS EVENTS ON (EVENTS.event_sid = CR.event_rsid)
WHERE
((ISNULL(CR.noticedt, GETDATE()) <= GETDATE()) or (ISNULL(DLY.clsddate, '20990101') <= GETDATE()))
AND ISNULL(DLY.CreateDate, '19000101') <= GETDATE() and (ISNULL(DLY.DeleteDate,'21990101') > GETDATE())
AND (EVENTS.event_year > '2015' AND EVENTS.pcs_cat_number IS NOT NULL) 
OR EVENTS.event_code IN ('17Q001','17Q002', '18H047')