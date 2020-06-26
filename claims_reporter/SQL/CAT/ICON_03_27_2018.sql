SELECT 
    CC.D55_CAT_CODE AS "Catastrophe Code" 
	,Year (CC.B70_LOSS_DATE) as "Catastrophe Year"
    ,CC.D87_ACC_STATE as "Catastrophe State"
    ,CC.D87_ACC_STATE as "Claim Accident State"
    ,CASE WHEN NAD3.B27_NAME1 = 'Evanston Insurance Company' THEN 'Evanston Insurance Company (EIC)'
			WHEN NAD3.B27_NAME1 = 'Markel American Insurance Company' THEN 'Markel American Insurance Company (MAIC)' 
			WHEN NAD3.B27_NAME1 = 'Markel Insurance Company' THEN 'Markel Insurance Company (MIC)'
			ELSE NAD3.B27_NAME1
			END as "Legal Entity"
    ,'' AS "Loss Type"
    ,'' AS "Product Line"
    ,'' AS "Region"
    ,NAD1.B27_NAME1 as "Claim Examiner"
    ,'ICON' AS "Source System"
    ,CC.B69_CLAIM_OCCUR AS "Claim Number"
    ,'' AS "CLM Count"
    ,CAST(CC.B70_LOSS_DATE AS DATE) as "Accident Date"
    ,CAST(CC.D43_REPORTED_DATE AS DATE) as "Reported Date"
    ,CASE WHEN CC.E87_STATUS = 2 THEN 'Closed' ELSE 'Open' END AS "Claim Status"
    ,CASE WHEN CC.E87_STATUS = 2 THEN CAST(CC.E87_STATUS_DATE AS DATE) 
			ELSE NULL END AS "Closed Date"
    ,NAD2.B27_NAME1 AS "Primary Insured Name"
    ,'' AS "Claimant Name"
    ,CC.A00_PNUM as "Policy Number"
    ,CAST(CC.A29_FDATE AS DATE) AS "Policy Effective Date"
    ,NAD2.B32_ZIP AS "Zip Code"
    ,NAD2.B31_STATE AS "State"
    ,'' AS "County"
    ,CASE WHEN CR.E62_ASL IS NULL THEN ''
    ELSE CR.E62_ASL END AS "ASL Code"
    ,CASE WHEN COV.E62_ASL_DESC IS NULL THEN ''
    ELSE COV.E62_ASL_DESC END AS "ASL Description"
    ,'' AS "Product Description"
    ,'' AS "Peril Description"
    ,'' AS "Coverage Description"
    ,CR.E93_DI_LOSS AS "Loss Reserves"
	,CR.F04_DI_LOSS_PAID AS "Loss Paid"
	,CR.E99_DI_EXP AS "Expense Reserves"
	,CR.F09_DI_EXP_PAID AS "Expense Paid"
	,CR.E93_DI_LOSS + CR.E99_DI_EXP + CR.F04_DI_LOSS_PAID + CR.F09_DI_EXP_PAID AS "Total Incurred (incl. ACR)"
	,'' AS "Additional Case Reserve (ACR)"
	,CR.E99_DI_EXP + CR.F09_DI_EXP_PAID AS "Total Expense"
	,CR.E93_DI_LOSS + CR.E99_DI_EXP + CR.F04_DI_LOSS_PAID + CR.F09_DI_EXP_PAID AS "Total Calculated Incurred (incl. ACR)"   /*should include ACR for ERMS*/
	,(CR.E93_DI_LOSS + CR.E99_DI_EXP + CR.F04_DI_LOSS_PAID + CR.F09_DI_EXP_PAID) - (CR.E93_DI_LOSS + CR.E99_DI_EXP + CR.F04_DI_LOSS_PAID + CR.F09_DI_EXP_PAID) AS "Differences"
	,CR.E93_DI_LOSS + CR.F04_DI_LOSS_PAID AS "Case Incurred Loss"
	,'' AS "Open CLM Count"
	,'' AS "Closed CLM Count"
	,'' AS "CLMS Closed with Payment"
	,'' AS "CLMS Closed without Payment"
	,CASE CR.E62_ASL 
        WHEN '-99' THEN 'Unidentified'
        WHEN '-98' THEN 'Unidentified'
        WHEN '-97' THEN 'Unidentified'
        WHEN '-1' THEN 'Unidentified'
        --WHEN NULL THEN 'Unidentified'
        WHEN '' THEN 'Unidentified'
        WHEN '0' THEN 'Unidentified'
        WHEN '01' THEN 'Other Liability'
        WHEN '010' THEN 'Fire'
        WHEN '021' THEN 'Allied Lines'
        WHEN '022' THEN 'Crop Multiple Peril'
        WHEN '023' THEN 'Federal Flood'
        WHEN '030' THEN 'Farmowners Multiple Peril'
        WHEN '031' THEN 'Farmowners Multiple Peril'
        WHEN '032' THEN 'Farmowners Multiple Peril'
        WHEN '040' THEN 'Homeowners Multiple Peril'
        WHEN '051' THEN 'Commercial Multiple Peril'
        WHEN '052' THEN 'Commercial Multiple Peril'
        WHEN '053' THEN 'Commercial Multiple Peril'
        WHEN '054' THEN 'Commercial Multiple Peril'
        WHEN '060' THEN 'Mortgage Guaranty'
        WHEN '080' THEN 'Ocean Marine'
        WHEN '083' THEN 'Ocean Marine'
        WHEN '090' THEN 'Inland Marine'
        WHEN '091' THEN 'Inland Marine'
        WHEN '100' THEN 'Financial Guaranty'
        WHEN '110' THEN 'Medical Malpractice'
        WHEN '111' THEN 'Medical Professional Liability - Occurrence'
        WHEN '112' THEN 'Medical Professional Liability - Claims Made'
        WHEN '120' THEN 'Earthquake'
        WHEN '130' THEN 'Group Accident and Health'
        WHEN '140' THEN 'Credit Accident and Health (Group and Individual)'
        WHEN '151' THEN 'Other Accident and Health'
        WHEN '152' THEN 'Other Accident and Health'
        WHEN '153' THEN 'Other Accident and Health'
        WHEN '154' THEN 'Other Accident and Health'
        WHEN '155' THEN 'Other Accident and Health'
        WHEN '156' THEN 'Other Accident and Health'
        WHEN '157' THEN 'Other Accident and Health'
        WHEN '158' THEN 'Other Accident and Health'
        WHEN '160' THEN 'Workers Compensation'
        WHEN '170' THEN 'Other Liability'
        WHEN '171' THEN 'Other Liability - Occurrence'
        WHEN '172' THEN 'Other Liability - Claims Made'
        WHEN '173' THEN 'Excess Workers Compensation'
        WHEN '174' THEN 'Other Liability'
        WHEN '180' THEN 'Products Liability'
        WHEN '181' THEN 'Products Liability - Occurrence'
        WHEN '182' THEN 'Products Liability - Claims Made'
        WHEN '191' THEN 'Private Passenger Auto Liability'
        WHEN '192' THEN 'Private Passenger Auto Liability'
        WHEN '193' THEN 'Commercial Auto Liability'
        WHEN '194' THEN 'Commercial Auto Liability'
        WHEN '202' THEN 'Commercial Auto Liability'
        WHEN '210' THEN 'Allied Lines'
        WHEN '211' THEN 'Private Passenger Auto'
        WHEN '212' THEN 'Auto Physical Damage'
        WHEN '220' THEN 'Aircraft (All Perils)'
        WHEN '230' THEN 'Fidelity'
        WHEN '240' THEN 'Surety'
        WHEN '250' THEN 'Allied Lines'
        WHEN '260' THEN 'Burglary and Theft'
        WHEN '270' THEN 'Boiler and Machinery'
        WHEN '280' THEN 'Credit'
        WHEN '290' THEN 'International'
        WHEN '300' THEN 'Warranty'
        WHEN '301' THEN 'Reinsurance - Non-Proportional Assumed Property'
        WHEN '310' THEN 'Reinsurance - Non-Proportional Assumed Property'
        WHEN '320' THEN 'Reinsurance - Non-Proportional Assumed Liability'
        WHEN '330' THEN 'Reinsurance - Non-Proportional Assumed Financial Lines'
        WHEN '341' THEN 'Tuition Reimbursement'
        WHEN '342' THEN 'Aggregate Write-in'
        WHEN '400' THEN 'Residential Property'
        WHEN '510' THEN 'Commercial Multiple Peril'
        WHEN '800' THEN 'Ocean Marine'
        WHEN '900' THEN 'Inland Marine'
        WHEN '1200' THEN 'Commercial Property'
        WHEN '1701' THEN 'General Liability'
        WHEN '1702' THEN 'General Liability'
        ELSE 'Unidentified'
		END AS "Category" 
	,'' AS "Comments"


    FROM  RAW_ICON.ICON.CCOMMON CC

    LEFT JOIN RAW_ICON.ICON.CRESERVE CR
    ON CR.B69_CLAIM_OCCUR = CC.B69_CLAIM_OCCUR

    LEFT JOIN RAW_ICON.ICON.NAME_ADDRESS NAD1
    ON NAD1.E04_ORIGNUM = CC.R30_IN_HOUSE_ADJ
    AND NAD1.E04_NEXT IS NULL
    
    LEFT JOIN RAW_ICON.ICON.NAME_ADDRESS NAD2
    ON NAD2.E04_ORIGNUM = CC.E04_INSURED_NUM
    AND NAD2.E04_NEXT IS NULL

    LEFT JOIN RAW_ICON.ICON.COMPANY CO
    ON CC.A01_COMPANY = CO.A01_COMPANY

    LEFT JOIN RAW_ICON.ICON.NAME_ADDRESS NAD3
    ON NAD3.E04_ORIGNUM = CO.E04_NAMENUM 
    AND NAD3.E04_NEXT IS NULL

    LEFT JOIN (
        SELECT * from [RAW_ICON].[ICON].[LA01_SBL_COV_ALL]
        where A01_COMPANY_CODE = '02' AND A36_GROUPLINE_CODE = '85'
        AND B80_USERLINE_CODE = '36' AND E62_ASL_CODE = '052' AND B97_SBL_CODE = '334'
        AND C87_COVERAGE_CODE = '101' and B97_SBL_DESC = 'Premises/Operations Liability - Claims Made'
        union all
        SELECT * from [RAW_ICON].[ICON].[LA01_SBL_COV_ALL]
        where (A01_COMPANY_CODE <> '02' AND A36_GROUPLINE_CODE <> '85'
        AND B80_USERLINE_CODE <> '36' AND E62_ASL_CODE <> '052' AND B97_SBL_CODE <> '334'
        AND C87_COVERAGE_CODE <> '101')) COV
    ON COV.B80_USERLINE_CODE = CR.B80_USERLINE
        AND COV.E62_ASL_CODE = CR.E62_ASL 
            AND COV.B97_SBL_CODE = CR.B97_SBL
              AND COV.C87_COVERAGE_CODE = CR.C87_COVERAGE
                AND COV.A36_GROUPLINE_CODE = CC.A36_GROUPLINE
                    AND COV.A01_COMPANY_CODE = CR.A01_COMPANY

    where D55_CAT_CODE IS NOT NULL and Year (CC.B70_LOSS_DATE) >= '2016'

    ORDER BY 
		CC.D55_CAT_CODE
		,CC.B70_LOSS_DATE
		,CC.D87_ACC_STATE
		,CC.B69_CLAIM_OCCUR
		,NAD3.B27_NAME1