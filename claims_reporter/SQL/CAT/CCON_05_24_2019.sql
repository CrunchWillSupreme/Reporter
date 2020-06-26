/* CCON */
SELECT 
    CC.D55_CAT_CODE AS "Catastrophe Code" 
	,Year (CC.B70_LOSS_DATE) as "Catastrophe Year"
    ,CC.D87_ACC_STATE as "Catastrophe State"
    ,CC.D87_ACC_STATE as "Claim Accident State"
    ,CASE WHEN NAD3.B27_NAME1 = 'Essentia Insurance Company' THEN 'Essentia Insurance Company (Essentia)'
            WHEN NAD3.B27_NAME1 = 'Nationwide Assumed' THEN 'Nationwide Mutual Insurance Company (Nationwide)'
			ELSE NAD3.B27_NAME1
			END as "Legal Entity"
    --,T.D60_LOSS_DESC as "Loss Type"
    ,'' AS "Loss Type"
    ,'' AS "Product Line"
    ,'' AS "Region"
    ,CASE WHEN NAD1.B27_NAME1 = 'Bill Mulvihill' THEN 'Hagerty Adjuster' 
    ELSE NAD1.B27_NAME1 END as "Claim Examiner"
    ,'CCON' AS "Source System"
    ,CC.B69_CLAIM_OCCUR AS "Claim Number"
    ,'' AS "CLM Count"
    ,CAST(CC.B70_LOSS_DATE AS DATE) as "Accident Date"
    ,CAST(CC.D43_REPORTED_DATE AS DATE) as "Reported Date"
    ,CASE WHEN CC.E87_STATUS = 2 THEN 'Closed' ELSE 'Open' END AS "Claim Status"
    ,CASE WHEN CC.E87_STATUS = 2 THEN CAST(CC.E87_STATUS_DATE AS DATE) 
			ELSE NULL END AS "Closed Date"
    ,NAD2.B27_NAME1 AS "Primary Insured Name"
    ,NAC.B27_NAME1 as "Claimant Name"
    ,CC.A00_PNUM as "Policy Number"
    ,CAST(CC.A29_FDATE AS DATE) AS "Policy Effective Date"
    ,NAD2.B32_ZIP AS "Zip Code"
    ,NAD2.B31_STATE AS "State"
    ,'' AS "County"
    ,CR.E62_ASL AS "ASL Code"
    ,COV.E62_ASL_DESC AS "ASL Description"
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
       WHEN '0' THEN 'Unidentified'
		WHEN '01' THEN 'Fire'
		WHEN '010' THEN 'Commercial Property'
		WHEN '021' THEN 'Allied Lines'
		WHEN '022' THEN 'Crop Multi-Peril/Aircraft (all perils)'
		WHEN '030' THEN 'Farmowners Multi-Peril'
		WHEN '040' THEN 'Homeowners Multi-Peril'
		WHEN '051' THEN 'Commercial Multi-Peril'
		WHEN '052' THEN 'Commercial Multi-Peril'
		WHEN '080' THEN 'Ocean Marine'
		WHEN '083' THEN 'Ocean Marine Inland'
		WHEN '090' THEN 'Inland Marine'
		WHEN '100' THEN 'Property'
		WHEN '112' THEN 'Medical Malpractice'
		WHEN '156' THEN 'Medical Title XVIII (State Taxes or Fees Exempt)'
		WHEN '170' THEN 'Other Liability'
       WHEN '171' THEN 'Other Liability (Occurence)'
		WHEN '172' THEN 'Other Liability (Claims Made)'
       WHEN '180' THEN 'Products Liability'
       WHEN '191' THEN 'Private Passenger Auto Liability'
       WHEN '192' THEN 'Private Passenger Auto Liability'
		WHEN '193' THEN 'Commercial Auto Liability'
		WHEN '194' THEN 'Commercial Auto Liability'
		WHEN '210' THEN 'Allied Lines'
		WHEN '211' THEN 'Private Passenger Auto'
		WHEN '212' THEN 'Commercial Auto'
		WHEN '270' THEN 'Boiler and Machinery'
		WHEN '400' THEN 'Residential Property'
		WHEN '510' THEN 'Commercial Multi-Peril'
		WHEN '800' THEN 'Ocean Marine Inland'
		WHEN '900' THEN 'Inland Marine'
		WHEN '1200' THEN 'Commercial Property'
		WHEN '1701' THEN 'General Liability'
		WHEN '1702' THEN 'General Liability'
       ELSE 'Unidentified'
		END AS "Category"
	,'' AS "Comments"
    FROM  RAW_CCON.ICON.CCOMMON CC

    LEFT JOIN RAW_CCON.ICON.CRESERVE CR
    ON CR.B69_CLAIM_OCCUR = CC.B69_CLAIM_OCCUR

    LEFT JOIN RAW_CCON.ICON.NAME_ADDRESS NAD1
    ON NAD1.E04_ORIGNUM = CC.R30_IN_HOUSE_ADJ
    AND NAD1.E04_NEXT IS NULL
    
    LEFT JOIN RAW_CCON.ICON.NAME_ADDRESS NAD2
    ON NAD2.E04_ORIGNUM = CC.E04_INSURED_NUM
    AND NAD2.E04_NEXT IS NULL

    LEFT JOIN RAW_CCON.ICON.COMPANY CO
    ON CC.A01_COMPANY = CO.A01_COMPANY

    LEFT JOIN RAW_CCON.ICON.NAME_ADDRESS NAD3
    ON NAD3.E04_ORIGNUM = CO.E04_NAMENUM 
    AND NAD3.E04_NEXT IS NULL

    LEFT JOIN RAW_CCON.ICON.NAME_ADDRESS NAC
	ON CR.E04_CLAIMANT_NUM = NAC.E04_ORIGNUM
	AND NAC.E04_NEXT IS NULL
	--LEFT JOIN RAW_CCON.ICON.LD60_LOSS_TYPES T
	--ON T.D60_LOSS_TYPE = CR.D60_TYPE_OF_LOSS AND T.C87_COVERAGE_CODE = CR.C87_COVERAGE

    LEFT JOIN [RAW_CCON].[ICON].LA01_SBL_COV_ALL COV
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
