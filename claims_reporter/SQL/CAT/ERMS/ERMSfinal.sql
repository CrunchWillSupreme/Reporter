SELECT

	ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code) AS 'Catastrophe Code'
	,ISNULL(YEAR(evdate), '20' + LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 2)) AS 'Catastrophe Year'
	,CASE WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1747' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1748' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1749' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1754' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1755' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1756' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1745' THEN 'PR'
		WHEN CR.state = '' AND CR.location = 'US/VI locations' THEN 'USVI'
		WHEN CR.state = '' AND CR.location LIKE '%Caribbean%' THEN 'CAR'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '17Q0' THEN 'MEX'
		WHEN CR.state IS NULL THEN 'UNK'
		WHEN CR.state = '' THEN 'UNK'
		ELSE CR.state END AS 'Catastrophe State'
	,CASE WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1747' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1748' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1749' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1754' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1755' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1756' THEN 'CA'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '1745' THEN 'PR'
		WHEN CR.state = '' AND CR.location = 'US/VI locations' THEN 'USVI'
		WHEN CR.state = '' AND CR.location LIKE '%Caribbean%' THEN 'CAR'
		WHEN CR.state = '' AND LEFT(ISNULL(EVENTS.pcs_cat_number, EVENTS.event_code), 4) = '17Q0' THEN 'MEX'
		WHEN CR.state IS NULL THEN 'UNK'
		WHEN CR.state = '' THEN 'UNK' 
		ELSE CR.state END AS 'Accident State' --check ERMS vba
	,CASE WHEN P.companyname = 'Alterra America Insurance Company' THEN 'Alterra America Insurance Company (AAIC)'
		WHEN P.companyname = 'Evanston Insurance Company' THEN 'Evanston Insurance Company (EIC)'
		WHEN P.companyname = 'Evanston  Insurance  Company' THEN 'Evanston Insurance Company (EIC)'
		WHEN P.companyname = 'Markel American Insurance Company' THEN 'Markel American Insurance Company (MAIC)'
		WHEN P.companyname = 'Markel Bermuda Limited' THEN 'Markel Bermuda Limited (MBL)'
		WHEN P.companyname = 'Markel Global Reinsurance Company' THEN 'Markel Global Reinsurance Company (MGRC)'
		WHEN P.companyname = 'Markel Insurance Company' THEN 'Markel Insurance Company (MIC)'
		ELSE P.companyname END AS 'Legal Entity'
	,COL.[description] AS 'Loss Type'
	,C7.name AS 'Product Line'
	,LC.locationname AS 'Region'
	,C6.PersonName AS 'Claim Examiner'
	,'ERMS' AS 'Source System'
	,DLY.maxclaimid AS 'Claim Number'
	,'' AS 'CLM Count'
	,left(cast(evdate as date), 10) AS 'Accident Date'
	,left(cast(noticedt as date), 10) AS 'Reported Date'
	,CASE WHEN C5.charcode = 'CLOSEDERROR' THEN 'Closed'
	WHEN C5.charcode = 'RECLOSED' THEN 'Closed'
    WHEN C5.charcode = 'CLOSED' THEN 'Closed'
	WHEN C5.charcode = 'REOPENED' THEN 'Open'
    WHEN C5.charcode = 'OPEN' THEN 'Open'
	ELSE C5.charcode 
	END AS 'Claim Status'
	,left(cast(clsddate as date), 10) AS 'Closed Date'
	,CR.insured AS 'Primary Insured Name'
	,CR.claimant AS 'Claimant Name'
	,d.policynum AS 'Policy Number'
	,left(cast(LB.incept as date), 10) AS 'Policy Effective Date'
	,CR.location AS 'Zip Code'
	,dly.RiskState AS 'State'
	,CR.county AS 'County'
	,DLY.ASL AS 'ASL Code'
    ,CR.losscode AS 'ASL Description'
	,LOB.Name AS 'Product Description'
	,E.exposurename AS 'Peril Description'
	,C8.name AS 'Coverage Description'
	,CDM.TotalOutstandingIndemnity AS 'Loss Reserves'
	,CD.TotalPaidIndemnity AS 'Loss Paid'
	,CDM.TotalOutstandingExpense AS 'Expense Reserves'
	,CD.TotalPaidExpense AS 'Expense Paid'
	,TI.MaxTotalIncurredInclACR AS 'Total Incurred (incl. ACR)'
	,ISNULL( CDM.TotalOutstandingACR, 0) AS 'Additional Case Reserve (ACR)'
	,CDM.TotalOutstandingExpense + CD.TotalPaidExpense AS 'Total Expense'
	,CDM.TotalOutstandingIndemnity + CD.TotalPaidIndemnity + CDM.TotalOutstandingExpense + CD.TotalPaidExpense + ISNULL(CDM.TotalOutstandingACR, 0) AS 'Total Calculated Incurred (incl. ACR)'
	,TI.MaxTotalIncurredInclACR - (CDM.TotalOutstandingIndemnity + CD.TotalPaidIndemnity + CDM.TotalOutstandingExpense + CD.TotalPaidExpense + ISNULL(CDM.TotalOutstandingACR, 0)) AS 'Differences'
	,CDM.TotalOutstandingIndemnity + CD.TotalPaidIndemnity AS 'Case Incurred Loss'
	,'' AS 'Open CLM Count'
	,'' AS 'Closed CLM Count'
	,'' AS 'CLMS Closed with Payment'
	,'' AS 'CLMS Closed without Payment'
	,CASE DLY.ASL 
        WHEN '-99' THEN 'Unidentified'
        WHEN '-98' THEN 'Unidentified'
        WHEN '-97' THEN 'Unidentified'
        WHEN '-1' THEN 'Unidentified'
        WHEN '' THEN 'Unidentified'
        WHEN '0' THEN 'Unidentified'
        WHEN '001' THEN 'Other Liability'
        WHEN '0010' THEN 'Fire'
        WHEN '0021' THEN 'Allied Lines'
        WHEN '0022' THEN 'Crop Multiple Peril'
        WHEN '0023' THEN 'Federal Flood'
        WHEN '0030' THEN 'Farmowners Multiple Peril'
        WHEN '0031' THEN 'Farmowners Multiple Peril'
        WHEN '0032' THEN 'Farmowners Multiple Peril'
        WHEN '0040' THEN 'Homeowners Multiple Peril'
        WHEN '0051' THEN 'Commercial Multiple Peril'
        WHEN '0052' THEN 'Commercial Multiple Peril'
        WHEN '0053' THEN 'Commercial Multiple Peril'
        WHEN '0054' THEN 'Commercial Multiple Peril'
        WHEN '0060' THEN 'Mortgage Guaranty'
        WHEN '0080' THEN 'Ocean Marine'
        WHEN '0083' THEN 'Ocean Marine'
        WHEN '0090' THEN 'Inland Marine'
        WHEN '0091' THEN 'Inland Marine'
        WHEN '0100' THEN 'Financial Guaranty'
        WHEN '0110' THEN 'Medical Malpractice'
        WHEN '0111' THEN 'Medical Professional Liability - Occurrence'
        WHEN '0112' THEN 'Medical Professional Liability - Claims Made'
        WHEN '0120' THEN 'Earthquake'
        WHEN '0130' THEN 'Group Accident and Health'
        WHEN '0140' THEN 'Credit Accident and Health (Group and Individual)'
        WHEN '0151' THEN 'Other Accident and Health'
        WHEN '0152' THEN 'Other Accident and Health'
        WHEN '0153' THEN 'Other Accident and Health'
        WHEN '0154' THEN 'Other Accident and Health'
        WHEN '0155' THEN 'Other Accident and Health'
        WHEN '0156' THEN 'Other Accident and Health'
        WHEN '0157' THEN 'Other Accident and Health'
        WHEN '0158' THEN 'Other Accident and Health'
        WHEN '0160' THEN 'Workers Compensation'
        WHEN '0170' THEN 'Other Liability'
        WHEN '0171' THEN 'Other Liability - Occurrence'
        WHEN '0172' THEN 'Other Liability - Claims Made'
        WHEN '0173' THEN 'Excess Workers Compensation'
        WHEN '0174' THEN 'Other Liability'
        WHEN '0180' THEN 'Products Liability'
        WHEN '0181' THEN 'Products Liability - Occurrence'
        WHEN '0182' THEN 'Products Liability - Claims Made'
        WHEN '0191' THEN 'Private Passenger Auto Liability'
        WHEN '0192' THEN 'Private Passenger Auto Liability'
        WHEN '0193' THEN 'Commercial Auto Liability'
        WHEN '0194' THEN 'Commercial Auto Liability'
        WHEN '0202' THEN 'Commercial Auto Liability'
        WHEN '0210' THEN 'Allied Lines'
        WHEN '0211' THEN 'Private Passenger Auto'
        WHEN '0212' THEN 'Auto Physical Damage'
        WHEN '0220' THEN 'Aircraft (All Perils)'
        WHEN '0230' THEN 'Fidelity'
        WHEN '0240' THEN 'Surety'
        WHEN '0250' THEN 'Allied Lines'
        WHEN '0260' THEN 'Burglary and Theft'
        WHEN '0270' THEN 'Boiler and Machinery'
        WHEN '0280' THEN 'Credit'
        WHEN '0290' THEN 'International'
        WHEN '0300' THEN 'Warranty'
        WHEN '0301' THEN 'Reinsurance - Non-Proportional Assumed Property'
        WHEN '0310' THEN 'Reinsurance - Non-Proportional Assumed Property'
        WHEN '0320' THEN 'Reinsurance - Non-Proportional Assumed Liability'
        WHEN '0330' THEN 'Reinsurance - Non-Proportional Assumed Financial Lines'
        WHEN '0341' THEN 'Tuition Reimbursement'
        WHEN '0342' THEN 'Aggregate Write-in'
        WHEN '0400' THEN 'Residential Property'
        WHEN '0510' THEN 'Commercial Multiple Peril'
        WHEN '0800' THEN 'Ocean Marine'
        WHEN '0900' THEN 'Inland Marine'
        WHEN '1200' THEN 'Commercial Property'
        WHEN '1701' THEN 'General Liability'
        WHEN '1702' THEN 'General Liability'
		END AS "Category" 
	,'' AS 'Comments'

FROM #tttt tttt
INNER JOIN ERMS.dbo.tbl_deals AS D ON tttt.dealnum = D.dealnum
INNER JOIN ERMS.dbo.tbl_claim_dly AS DLY ON (tttt.claimdly_sid = DLY.claimdly_sid)
INNER JOIN ERMS.dbo.tb_claim AS CR ON (tttt.claim_sid = CR.claim_sid)
INNER JOIN ERMS.dbo.tb_deallayeryr LY ON LY.dealnum = DLY.dealnum and LY.layer = DLY.layer and LY.yearnum = DLY.yearnum
LEFT OUTER JOIN ERMS.dbo.v_layerbnd AS LB ON (DLY.dealnum = LB.dealnum and DLY.layer = LB.layer and DLY.yearnum = LB.yearnum)
LEFT OUTER JOIN ERMS.dbo.tb_location AS LC ON (LC.locationid = D.sourcelocation)
LEFT OUTER JOIN ERMS.dbo.tb_company AS CMPNY ON (CMPNY.companysid = LC.companyrsid)
LEFT OUTER JOIN ERMS.dbo.v_dealretro_pcts_ext PCT ON PCT.dealnum = DLY.dealnum and PCT.Layer = DLY.layer and PCT.yearnum = DLY.yearnum
LEFT OUTER JOIN ERMS.dbo.tb_claim_col AS COL ON (COL.col_id = DLY.col_id)
/* Gross figures ; always totals */
LEFT OUTER JOIN ERMS.dbo.tb_claim_rpt_total AS CDG
ON (CDG.claim_rsid = CR.claim_sid AND CDG.claimrpttot_sid = (SELECT TOP 1 claimrpttot_sid FROM ERMS.dbo.tb_claim_rpt_total TMP
    WHERE CR.claim_sid = TMP.claim_rsid AND TMP.hdate <= GETDATE() ORDER BY hdate DESC, claimrpttot_sid DESC))
/* MaxRe figures ; paid are always totals */
LEFT OUTER JOIN ERMS.dbo.tb_claim_rsv_total AS CDM
ON (DLY.claimdly_sid = CDM.claimdly_rsid AND CDM.claimrsvtot_sid = (SELECT TOP 1 claimrsvtot_sid FROM ERMS.dbo.tb_claim_rsv_total TMP
    WHERE TMP.claimdly_rsid = CDM.claimdly_rsid AND TMP.hdate <= GETDATE() ORDER BY hdate DESC, claimrsvtot_sid DESC))
--  /* MaxRe outstanding ; will be summed */
--  LEFT OUTER JOIN tb_claim_rsv_total as CD
--    ON (DLY.claimdly_sid = CD.claimdly_rsid AND CD.hdate <= GETDATE())
INNER JOIN ERMS.dbo.tb_paper AS P ON (D.paper = P.papernum)
INNER JOIN ERMS.dbo.tb_currency AS R ON (CR.currency = R.currency)
LEFT OUTER JOIN ERMS.dbo.tb_catalogitems AS C1 ON (D.reinsurance = C1.code and C1.catid = 79)
INNER JOIN ERMS.dbo.dmUnderwritingTeam UW ON D.producer = UW.UnderwritingTeamPK
--  LEFT OUTER JOIN tb_catalogitems as c2 on (d.producer = c2.code and c2.catid = 80)
LEFT OUTER JOIN ERMS.dbo.tb_catalogitems AS C3 ON (D.riskcatagory = C3.code and C3.catid = 77)
LEFT OUTER JOIN ERMS.dbo.tb_catalogitems AS C4 ON (D.policybasis = C4.code and C4.catid = 81)
LEFT OUTER JOIN ERMS.dbo.tb_catalogitems AS C5 ON (DLY.status = C5.code and C5.catid = 124)
LEFT OUTER JOIN ERMS.dbo.tb_catalogitems AS C8 ON (D.busclass = C8.code and C8.catid = 78)
LEFT OUTER JOIN ERMS.dbo.tb_Person AS C6 ON (CR.handler = c6.PersonId)
LEFT OUTER JOIN ERMS.dbo.tb_Person AS C9 ON (CR.reviewer = c9.PersonId)
LEFT OUTER JOIN ERMS.dbo.tb_Person AS C10 ON (CR.manager = c10.PersonId)
LEFT OUTER JOIN ERMS.dbo.tb_exposetype AS E ON (D.exposuretype = E.exposuretype)
LEFT OUTER JOIN ERMS.dbo.tb_underwriter AS U ON (U.uwnum = D.uw1)
LEFT OUTER JOIN ERMS.dbo.tb_riskband AS B ON (D.riskband = B.code)
LEFT OUTER JOIN ERMS.dbo.tb_counterparty AS CPLAW ON (CPLAW.cpartynum = CR.lawfirm AND CPLAW.entitytype = 11)
LEFT OUTER JOIN ERMS.dbo.tb_contacts AS CTLAW ON (CTLAW.contactnum = CR.lawyer)
LEFT OUTER JOIN ERMS.dbo.tb_country AS COUNTRY ON (COUNTRY.cnum = CR.country)
LEFT OUTER JOIN ERMS.dbo.tb_claim_events AS EVENTS ON (EVENTS.event_sid = CR.event_rsid)
LEFT OUTER JOIN ERMS.dbo.tb_claim_events AS EVENTS2 ON (EVENTS.parent_event_code_id = EVENTS2.event_sid)
LEFT OUTER JOIN ERMS.dbo.tb_claim_parent_events AS PE ON (EVENTS.parent_event_sid = PE.parent_event_sid)
LEFT JOIN ERMS.dbo.tb_catalogitems AS C7 ON (D.busunit = C7.code and C7.catid = 34)
LEFT OUTER JOIN ERMS.dbo.tb_claim_totalincurred AS TI ON (TI.claimdly_rsid = DLY.claimdly_sid AND
          TI.totid = (SELECT TOP 1 totid FROM ERMS.dbo.tb_claim_totalincurred WHERE claimdly_rsid = dly.claimdly_sid AND hdate <= GETDATE() ORDER BY hdate DESC, totid DESC))
LEFT JOIN (SELECT _DR.dealnum, _DR.layer, _DR.yearnum, MAX(ISNULL( _TD.facultative, 0)) facultative
    FROM ERMS.dbo.tb_dealretro _DR
    INNER JOIN ERMS.dbo.tb_dealretrolayer _DRL ON _DRL.dealretroFK = _DR.dealretroPK
    INNER JOIN ERMS.dbo.tb_treatydtls _TD ON _TD.dealnum = _DR.retronum
		WHERE _TD.layer = _DRL.RetroLayer AND _DRL.isApplicable = 1
		GROUP BY _DR.dealnum, _DR.layer, _DR.yearnum ) DR ON DR.dealnum=d.dealnum AND DR.layer=DLY.layer and DR.yearnum=DLY.yearnum
  LEFT JOIN ERMS.dbo.CLM_ClaimCategories CLMCATS
    ON CR.claim_sid=CLMCATS.claim_rsid
  LEFT JOIN ERMS.dbo.tb_lpcat CLMCAT
    ON CLMCATS.category= CLMCAT.lpcat_id
  LEFT JOIN ERMS.dbo.tb_claim_ext_medicare MEDI
    ON MEDI.claim_rsid = CR.claim_sid

LEFT OUTER JOIN

(SELECT *

FROM (SELECT claimdly_rsid,
          SUM(ISNULL(TOT.totalpaidindemnity,0.0))   AS totalpaidindemnity,
          SUM(ISNULL(TOT.totalpaidexpense,0.0))     AS totalpaidexpense,
          SUM(ISNULL(TOT.totalpaid,0.0))            AS totalpaid,
          SUM(ISNULL(TOT.totalpaidindemnity,0.0)    *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As TotalPaidIndemnity_USD_SpotRate,
          SUM(ISNULL(TOT.totalpaidexpense,0.0)      *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As TotalPaidExpense_USD_SpotRate,
          SUM(ISNULL(TOT.totalpaid,0.0)             *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As TotalPaid_USD_SpotRate,
          SUM(ISNULL(TOT.totalpayableindemnity,0.0)) AS totalpayableindemnity,
          SUM(ISNULL(TOT.totalpayableexpense,0.0))   AS totalpayableexpense,
          SUM(ISNULL(TOT.totalpayable,0.0))          AS totalpayable,
          SUM(ISNULL(TOT.totalpayableindemnity,0.0)  *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As TotalpayableIndemnity_USD_SpotRate,
          SUM(ISNULL(TOT.totalpayableexpense,0.0)    *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As TotalpayableExpense_USD_SpotRate,
          SUM(ISNULL(TOT.totalpayable,0.0)           *ERMS.dbo.fn_fxrate(C.currency,'USD',hdate)) As Totalpayable_USD_SpotRate
       FROM ERMS.dbo.tb_claim_rsv_total TOT
       INNER JOIN ERMS.dbo.tbl_claim_dly CDLY ON TOT.claimdly_rsid = CDLY.claimdly_sid
       INNER JOIN ERMS.dbo.tb_claim C ON CDLY.claim_rsid = C.claim_sid
       WHERE TOT.hdate <= GETDATE()
         AND ISNull(CDLY.DeleteDate,'21990101') > GETDATE()
       GROUP BY claimdly_rsid) res2
                )  CD ON DLY.claimdly_sid = CD.claimdly_rsid
LEFT JOIN ERMS.dbo.tb_claim_LOB LOB
	ON DLY.claim_lobid = LOB.LOBID