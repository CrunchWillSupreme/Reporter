
SELECT * FROM (
SELECT DISTINCT
 D55_CAT_CODE as "Catastrophe Code"
	  ,YEAR (B70_LOSS_DATE) as "Catastrophe Year"
	  ,CC.D87_ACC_STATE as "Catastrophe State"
	  ,CASE CC.D87_ACC_STATE WHEN 'VI' THEN 'USVI' ELSE CC.D87_ACC_STATE END as "Claim Accident State"
	  ,CASE CC.A01_COMPANY WHEN '01' THEN 'Markel Insurance Company (MIC)'
	  WHEN '02' THEN 'Evanston Insurance Company (EIC)'
	  WHEN '05' THEN 'Markel American Insurance Company (MAIC)' 
	  WHEN '04' THEN 'Evanston Insurance Company (EIC) formerly Essex'
	  ELSE CC.A01_COMPANY END as "Legal Entity"
	  ,T.D60_LOSS_DESC as "Loss Type"
	  ,'' as "Product Line"
	  ,'' as "Region"
	  ,NAD.B27_NAME1 as "Claim Examiner"
	  ,'Paragon RV' as "Source System"
      ,CC.B69_CLAIM_OCCUR as "Claim Number"
	  ,'' as "CLM Count"
	  ,CAST(CC.B70_LOSS_DATE AS DATE) as "Accident Date"
	  --,CC.B70_LOSS_DATE as "Accident Date"
	  ,CAST(CC.D43_REPORTED_DATE AS DATE) as "Reported Date"
	  ,CASE CC.E87_STATUS WHEN 0 THEN 'Open'
	  WHEN 1 THEN 'Open'
	  WHEN 2 THEN 'Closed'
	  WHEN 3 THEN 'Open For Recovery' ELSE NULL END as "Claim Status"
	  ,CASE CC.E87_STATUS WHEN 2 THEN CAST(CC.E87_STATUS_DATE AS DATE)
	  ELSE NULL END as "Closed Date"
	  ,NA.B27_NAME1 as "Primary Insured Name"
	  ,NAC.B27_NAME1 as "Claimant Name"
	  ,PC.A00_PNUM as "Policy Number"
	  ,CAST(PC.A08_FDATE AS DATE) as "Policy Effective Date"
	  --,COV.C07_LIMIT_1 as "Policy Limit"
	  ,LEFT(NA.B32_ZIP,5)  as "Zip Code"
	  ,NA.B31_STATE AS "State"
	  ,'' AS "County"
	  ,CR.E62_ASL "ASL Code"
	  ,COV.E62_ASL_DESC AS "ASL Description"
	  ,COV.B80_USERLINE_DESC as "Product Description"
	  ,'' AS "Peril Description"
	  ,'' AS "Coverage Description"
	  --,CC.R21_BUSINESS_UNIT
	  ,CR.E93_DI_LOSS as "Loss Reserves"
	  ,CR.F04_DI_LOSS_PAID as "Loss Paid"
	  ,CR.E99_DI_EXP as "Expense Reserves"
	  ,CR.F09_DI_EXP_PAID as "Expense Paid"
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
		END AS "Category" 
	  ,'' AS "Comments"

  FROM RAW_PARAGON_RV_MCYCL.SYS$DIA.CCOMMON CC
   LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.CRESERVE CR
	ON CC.B69_CLAIM_OCCUR = CR.B69_CLAIM_OCCUR
   LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.PCOMMON PC
	ON CC.A00_PNUM = PC.A00_PNUM
	AND CC.A06_EDITION = PC.A06_EDITION
  
	--LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.LB80_USERLINE LB
	-- ON CR.B80_USERLINE = LB.B80_USERLINE
	LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.NAME_ADDRESS NA
		ON CC.E04_INSURED_NUM = NA.E04_ORIGNUM
		  AND NA.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.NAME_ADDRESS NAD
		ON CC.R30_IN_HOUSE_ADJ = NAD.E04_ORIGNUM
		  AND NAD.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.NAME_ADDRESS NAC
		ON CR.E04_CLAIMANT_NUM = NAC.E04_ORIGNUM
		  AND NAC.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.LD60_LOSS_TYPES T
		ON T.D60_LOSS_TYPE = CR.D60_TYPE_OF_LOSS AND T.C87_COVERAGE_CODE = CR.C87_COVERAGE
    LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.LA01_SBL_COV COV
    ON COV.B80_USERLINE_CODE = CR.B80_USERLINE
        AND COV.E62_ASL_CODE = CR.E62_ASL 
            AND COV.B97_SBL_CODE = CR.B97_SBL
              AND COV.C87_COVERAGE_CODE = CR.C87_COVERAGE
                AND COV.A36_GROUPLINE_CODE = CC.A36_GROUPLINE
                    AND COV.A01_COMPANY_CODE = CR.A01_COMPANY
	WHERE 
    --D55_CAT_CODE IS NOT NULL
	CC.B70_LOSS_DATE BETWEEN '2019-05-18' AND '2019-05-24'
	AND CC.B69_CLAIM_OCCUR <> '17C3684'
    --AND CC.D87_ACC_STATE = 'NM'

UNION ALL

SELECT DISTINCT
 D55_CAT_CODE as "Catastrophe Code"
	  ,YEAR (B70_LOSS_DATE) as "Catastrophe Year"
	  ,CC.D87_ACC_STATE as "Catastrophe State"
	  ,CASE CC.D87_ACC_STATE WHEN 'VI' THEN 'USVI' ELSE CC.D87_ACC_STATE END as "Claim Accident State"
	  ,CASE CC.A01_COMPANY WHEN '01' THEN 'Markel Insurance Company (MIC)'
	  WHEN '02' THEN 'Evanston Insurance Company (EIC)'
	  WHEN '05' THEN 'Markel American Insurance Company (MAIC)' 
	  WHEN '04' THEN 'Evanston Insurance Company (EIC) formerly Essex'
	  ELSE CC.A01_COMPANY END as "Legal Entity"
	  ,T.D60_LOSS_DESC as "Loss Type"
	  ,'' as "Product Line"
	  ,'' as "Region"
	  ,NAD.B27_NAME1 as "Claim Examiner"
	  ,'Paragon Property' as "Source System"
      ,CC.B69_CLAIM_OCCUR as "Claim Number"
	  ,'' as "CLM Count"
	  ,CAST(CC.B70_LOSS_DATE AS DATE) as "Accident Date"
	  --,CC.B70_LOSS_DATE as "Accident Date"
	  ,CAST(CC.D43_REPORTED_DATE AS DATE) as "Reported Date"
	  ,CASE CC.E87_STATUS WHEN 0 THEN 'Open'
	  WHEN 1 THEN 'Open'
	  WHEN 2 THEN 'Closed'
	  WHEN 3 THEN 'Open For Recovery' ELSE NULL END as "Claim Status"
	  ,CASE CC.E87_STATUS WHEN 2 THEN CAST(CC.E87_STATUS_DATE AS DATE)
	  ELSE NULL END as "Closed Date"
	  ,NA.B27_NAME1 as "Primary Insured Name"
	  ,NAC.B27_NAME1 as "Claimant Name"
	  ,PC.A00_PNUM as "Policy Number"
	  ,CAST(PC.A08_FDATE AS DATE) as "Policy Effective Date"
	  --,COV.C07_LIMIT_1 as "Policy Limit"
	  ,LEFT(NA.B32_ZIP,5)  as "Zip Code"
	  ,NA.B31_STATE AS "State"
	  ,'' AS "County"
	  ,CR.E62_ASL "ASL Code"
	  ,COV.E62_ASL_DESC AS "ASL Description"
	  ,COV.B80_USERLINE_DESC as "Product Description"
	  ,'' AS "Peril Description"
	  ,'' AS "Coverage Description"
	  --,CC.R21_BUSINESS_UNIT
	  ,CR.E93_DI_LOSS as "Loss Reserves"
	  ,CR.F04_DI_LOSS_PAID as "Loss Paid"
	  ,CR.E99_DI_EXP as "Expense Reserves"
	  ,CR.F09_DI_EXP_PAID as "Expense Paid"
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
		END AS "Category" 
	  ,'' AS "Comments"

  FROM RAW_PARAGON_PROPERTY.PARAGON.CCOMMON CC
   LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.CRESERVE CR
	ON CC.B69_CLAIM_OCCUR = CR.B69_CLAIM_OCCUR
   LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.PCOMMON PC
	ON CC.A00_PNUM = PC.A00_PNUM
	AND CC.A06_EDITION = PC.A06_EDITION
  
	--LEFT JOIN RAW_PARAGON_RV_MCYCL.SYS$DIA.LB80_USERLINE LB
	-- ON CR.B80_USERLINE = LB.B80_USERLINE
	LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.NAME_ADDRESS NA
		ON CC.E04_INSURED_NUM = NA.E04_ORIGNUM
		  AND NA.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.NAME_ADDRESS NAD
		ON CC.R30_IN_HOUSE_ADJ = NAD.E04_ORIGNUM
		  AND NAD.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.NAME_ADDRESS NAC
		ON CR.E04_CLAIMANT_NUM = NAC.E04_ORIGNUM
		  AND NAC.E04_NEXT IS NULL
	LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.LD60_LOSS_TYPES T
		ON T.D60_LOSS_TYPE = CR.D60_TYPE_OF_LOSS AND T.C87_COVERAGE_CODE = CR.C87_COVERAGE
    LEFT JOIN RAW_PARAGON_PROPERTY.PARAGON.LA01_SBL_COV COV
    ON COV.B80_USERLINE_CODE = CR.B80_USERLINE
        AND COV.E62_ASL_CODE = CR.E62_ASL 
            AND COV.B97_SBL_CODE = CR.B97_SBL
              AND COV.C87_COVERAGE_CODE = CR.C87_COVERAGE
                AND COV.A36_GROUPLINE_CODE = CC.A36_GROUPLINE
                    AND COV.A01_COMPANY_CODE = CR.A01_COMPANY
	WHERE 
	CC.B70_LOSS_DATE BETWEEN '2019-05-18' AND '2019-05-24'
	AND CC.B69_CLAIM_OCCUR <> '17C3684'
    --AND CC.D87_ACC_STATE = 'NM'
)X
    ORDER BY [Catastrophe Code]
		,[Catastrophe Year]
		,[Claim Accident State]
		,[Claim Number]
		,[Legal Entity]