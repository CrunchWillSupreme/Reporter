IF OBJECT_ID('tempdb..##TEMP_RESULTS') IS NOT NULL DROP TABLE ##TEMP_RESULTS
		SELECT * 
		INTO ##TEMP_RESULTS
		FROM (
		select DISTINCT
		'PRIMIS' AS 'Legacy System'
		,ADJ.B27_NAME1 AS 'Examiner Name'
		,AT.D76_DESCRIPTION AS 'File Type'
		,CC.B69_CLAIM_OCCUR AS 'Claim Number'
		,CC.D87_ACC_STATE AS 'Loss State'
		,CASE CC.STATE_REPORTING
			WHEN '1' THEN 'Yes'
			WHEN  '2' THEN 'No'
				ELSE NULL END AS 'State Report Indicator'
		,CASE CC.NPDB_REPORTING
			WHEN '1' THEN 'Yes'
			WHEN '2' THEN 'No'
				ELSE NULL END AS 'NPDB Report Indicator'
		,CASE CC.E87_STATUS 
			WHEN 0 THEN 'Open'
			WHEN 1 THEN 'New'
			WHEN 2 THEN 'Closed'
			WHEN 3 THEN 'Open for Recovery'
			WHEN 4 THEN 'Void' ELSE CAST(CC.E87_STATUS AS varchar) END AS 'Folder Status'
		,CR.[F04_DI_LOSS_PAID] AS 'ITD Loss'
        ,CR.[F09_DI_EXP_PAID] AS 'ITD Expense'
		,CASE WHEN CR.B69_CLAIM_OCCUR IS NULL THEN NULL ELSE CONCAT(CR.B69_CLAIM_OCCUR,'-',CR.U10_CLMNUM) END AS 'Claim Feature Number'
		,NA1.B27_NAME1 AS 'Issuing Company'
		,CONCAT(CC.A00_PNUM,'-',CC.A06_EDITION) AS 'Policy Number/Edition'
		,CR.C07_LIMIT_3 AS 'Occurrence Limit'
		,CR.B85_DED_AMT AS 'Deductible'
		,NA2.B27_NAME1 AS 'Insured Name'
		,NA2.B28_ADDR1 AS 'Insured Address 1'
		,NA2.B28_ADDR2 AS 'Insured Address 2'
		,NA2.B30_CITY AS 'Insured City'
		,NA2.B31_STATE AS 'Insured State'
		,NA2.B32_ZIP AS 'Insured Zip'
		,PC.A02_RATING_STATE AS 'Risk State'
		,CLMT.B27_NAME1 AS 'Claimant Name'
		,CONCAT(CLMT.B28_ADDR1,' ',CLMT.B28_ADDR2) AS 'Claimant Address'
		,CLMT.B30_CITY AS 'Claimant City'
		,CLMT.B31_STATE AS 'Claimant State'
		,CLMT.B32_ZIP AS 'Claimant Zip'
		,CC.B70_LOSS_DATE AS 'Loss Date'
		,CC.G36_CLAIMS_MADE AS 'Claims Made Date'
		,CC.D43_REPORTED_DATE AS 'Reported Date'
		,CC.H53_NDATE AS 'Claim Folder Opened Date'
		,CASE WHEN CC.E87_STATUS = 3 THEN CC.E87_STATUS_DATE END AS 'Claim Folder Re-Opened Date'
		,CASE WHEN CC.E87_STATUS = 2 THEN CC.E87_STATUS_DATE END AS 'Claim Folder Closed Date'
		,CR.H53_NDATE AS 'Claim Feature Opened Date'
		,CASE WHEN CR.E87_STATUS = 2 THEN CR.E87_STATUS_DATE END AS 'Claim Feature Closed Date'
		,CC.[ERROR_BEGIN_DATE] AS 'Error Begin Date'
		,CC.[ERROR_END_DATE] AS 'Error End Date'
		,CASE CR.E87_STATUS 
			WHEN 0 THEN 'Open'
			WHEN 1 THEN 'New'
			WHEN 2 THEN 'Closed'
			WHEN 3 THEN 'Open for Recovery'
			WHEN 4 THEN 'Void' ELSE CAST(CR.E87_STATUS AS varchar) END AS 'Feature Status'
		,CLASS.B83_DESCRIPTION AS 'Prof. Activity of Insured'
		,CR.E93_DI_LOSS AS 'Outstanding Loss Reserve'
		,CR.E99_DI_EXP AS 'Outstanding Expense Reserve'
		,CC.ACTIVITY_DESC AS 'Coverage Result/Activity Status'
		,FD.FILE_DISPOSITION_VALUE AS 'File Disposition'
		,'' AS 'Settlement Date'
		,CASE 
			WHEN CC.D76_ACTIVITY_TYPE = 'U' THEN 'Yes'
			WHEN CC.A13_ACT_STATUS = 'IS' THEN 'Yes'
			ELSE NULL END AS 'In-Suit Indicator'

		,NULL AS 'Additional Notes'
		,NULL AS 'File Resolution'
		,NULL AS 'File Suffix'
		from RAW_PRIMIS.PRIMIS2.CCOMMON CC
		left join RAW_PRIMIS.PRIMIS2.CRESERVE CR
		ON CR.B69_CLAIM_OCCUR = CC.B69_CLAIM_OCCUR
		left join RAW_PRIMIS.PRIMIS2.PCOMMON PC
		ON PC.A00_PNUM = CC.A00_PNUM AND PC.A06_EDITION = CC.A06_EDITION
		left join RAW_PRIMIS.PRIMIS2.PCOVERAGE COV
		ON COV.A00_PNUM = PC.A00_PNUM AND COV.A06_EDITION = PC.A06_EDITION AND COV.B79_UNIT = CR.B79_UNIT AND COV.C87_COVERAGE = CR.C87_COVERAGE
		left join RAW_PRIMIS.PRIMIS2.PUNIT PU
		ON PU.A00_PNUM = PC.A00_PNUM AND PU.A06_EDITION = PC.A06_EDITION AND PU.B79_UNIT = CR.B79_UNIT
		left join RAW_PRIMIS.PRIMIS2.COMPANY CP
		ON CP.A01_COMPANY = CC.A01_COMPANY
		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS NA1
		ON NA1.E04_ORIGNUM = CP.E04_NAMENUM AND NA1.E04_NEXT IS NULL
		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS NA2
		ON NA2.E04_ORIGNUM = PC.E04_INS_ORIGNUM AND NA2.E04_NEXT IS NULL
		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS ADJ
		ON ADJ.E04_ORIGNUM = CC.R30_IN_HOUSE_ADJ AND ADJ.E04_NEXT IS NULL
		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS CLMT
		ON CLMT.E04_ORIGNUM = CR.E04_CLAIMANT_NUM AND CLMT.E04_NEXT IS NULL
		left join RAW_PRIMIS.PRIMIS2.LQ70_UNDERWRITER UW
		ON UW.Q70_UNDERWRITER = PC.Q70_UNDERWRITER
		left join RAW_PRIMIS.PRIMIS2.LB84_DED_TYPE DED
		ON DED.B84_DED_TYPE = COV.B84_DED_TYPE
		left join RAW_PRIMIS.PRIMIS2.LD76_ACTIVITY_TYPE AT
		ON AT.D76_ACTIVITY_TYPE = CC.D76_ACTIVITY_TYPE
		left join RAW_PRIMIS.PRIMIS2.LB83_CLASS_CODES CLASS
		ON CLASS.B83_CLASS = CR.B83_CLASS AND CLASS.B97_SUBLINE = CR.B97_SBL
		left join RAW_PRIMIS.PRIMIS2.FILE_DISPOSITION FD
		ON FD.FILE_DISPOSITION_ID = CC.FILE_DISPOSITION_ID
		WHERE 
		CC.B69_CLAIM_OCCUR LIKE 'SM%' OR CC.B69_CLAIM_OCCUR LIKE 'MM%' OR CC.B69_CLAIM_OCCUR LIKE 'LA%' OR CC.B69_CLAIM_OCCUR LIKE 'DO%'

		--UNION ALL

		--SELECT DISTINCT
		--'PROFIT' AS 'Source System'
		--,CH.HANDLER_NAME AS 'Examiner Name'
		--,CASE CM.FILE_TYPE
		--	WHEN 'E' THEN 'EEOC/State Charge'
		--	WHEN 'R' THEN 'Recovery/Subrogation'
		--	WHEN 'A' THEN 'Administrative Claim'
		--	WHEN 'X' THEN 'Reserves'
		--	WHEN 'F' THEN 'Fast Track'
		--	WHEN 'C' THEN 'Claim'
		--	WHEN 'M' THEN 'Criminal Action'
		--	WHEN 'O' THEN 'Record Only'
		--	WHEN 'P' THEN 'Lost Pay'
		--	WHEN 'V' THEN 'Civil Action'
		--	WHEN 'S' THEN 'Suit'
		--	WHEN 'I' THEN 'Incident'
		--	WHEN 'B' THEN 'Subpoena'
		--	WHEN 'N' THEN 'EEOC/National Counsel'
		--	WHEN 'Z' THEN 'No Claim'
		--		ELSE NULL END AS 'File Type'
		--,RTRIM(CM.FILE_NUMBER) AS 'Claim Number'
		--,CM.LOSS_STATE_PROVINCE AS 'Loss State'
		--,CASE ADL.STATE_REPORT_INDICATOR
		--	WHEN 'Y' THEN 'Yes'
		--	WHEN 'N' THEN 'No'
		--	WHEN 'Z' THEN 'N/A'
		--	ELSE NULL END AS 'State Report Indicator'
		--,CASE ADL.NPDB_REPORT_INDICATOR
		--	WHEN 'Y' THEN 'Yes'
		--	WHEN 'N' THEN 'No'
		--	WHEN 'Z' THEN 'N/A'
		--	ELSE NULL END AS 'NPDB Report Indicator'
		--,CASE CM.[FILE_STATUS]
		--WHEN 'C' THEN 'Closed'
		--WHEN 'O' THEN 'Open'
		--WHEN 'P' THEN 'Pending'
		--WHEN 'S' THEN 'Settled'
		--WHEN 'V' THEN 'Void' END AS 'Folder Status'
		--,CD.[UW_LOSS_PAYMENT] AS 'ITD Loss'
		--,CONCAT(RTRIM(CD.FILE_NUMBER),'-',RTRIM(CD.FILE_SUFFIX)) AS 'Claim Feature Number'
		--,COMP.ISSUING_COMPANY_NAME AS 'Issuing Company'
		--,CD.[POLICY_NUMBER] AS 'Policy Number/Edition'
		--,COV.PER_CLAIM_LIMIT AS 'Occurrence Limit'
		--,COV.[REPORTING_DEDUCTIBLE] AS 'Deductible'
		--,CM.[INSURED_NAME] AS 'Insured Name'
		--,RSK.RISK_ADDRESS_1 AS 'Insured Address 1'
		--,RSK.RISK_ADDRESS_2 AS 'Insured Address 2'
		--,RSK.RISK_CITY AS 'Insured City'
		--,RSK.RISK_STATE AS 'Insured State'
		--,RSK.RISK_ZIP_CODE AS 'Insured Zip'
		--,RSK.RISK_STATE AS 'Risk State'
		--,CM.CLAIMANT_NAME AS 'Claimant Name'
		--,CM.CLAIMANT_STREET AS 'Claimant Street'
		--,CM.CLAIMANT_CITY  AS 'Claimant City'
		--,CM.CLAIMANT_STATE_PROVINCE AS 'Claimant State'
		--,CM.CLAIMANT_ZIPCODE AS 'Claimant Zip'
		--,CM.[DATE_OF_ERROR_BEGIN] AS 'Loss Date'
		--,CM.DATE_CLAIM_MADE AS 'Claims Made Date'
		--,CM.DATE_REPORTED AS 'Reported Date'
		--,CM.[DATE_OPENED] AS 'Claim Folder Opened Date'
		--,CM.DATE_REOPENED AS 'Claim Folder Re-Opened Date'
		--,CM.[DATE_CLOSED] AS 'Claim Folder Closed Date'
		--,CD.DATE_OPENED AS 'Claim Feature Opened Date'
		--,CD.DATE_CLOSED AS 'Claim Feature Closed Date'
		--,CM.[DATE_OF_ERROR_BEGIN] AS 'Error Begin Date'
		--,CM.[DATE_OF_ERROR_END] AS 'Error End Date'
		--,CASE CD.[FILE_STATUS]
		--WHEN 'C' THEN 'Closed'
		--WHEN 'O' THEN 'Open'
		--WHEN 'V' THEN 'Void' END AS 'Feature Status'
		--,REPLACE(REPLACE(RTRIM(PP.SERVICES_RENDERED),CHAR(10),''),CHAR(13),'') AS 'Prof. Activity of Insured'
		--,CD.[UW_LEGAL_PAYMENT] AS 'ITD Expense'
		--,CD.[UW_LOSS_RESERVE] AS 'Outstanding Loss Reserve'
		--,CD.[UW_LEGAL_RESERVE]  AS 'Outstanding Expense Reserve'
		--,CASE CM.COVERAGE_RESULT
		--	WHEN 'R' THEN 'Referred to Another Carrier'
		--	WHEN 'A' THEN 'Accepted'
		--	WHEN 'U' THEN 'Unresolved'
		--	WHEN '9' THEN 'Transferred to Riverstone'
		--	WHEN 'X' THEN 'Settled during Trial'
		--	WHEN 'C' THEN 'Defense under Reservation of Rights, Cov Limitations Apply'
		--	WHEN 'M' THEN ''
		--	WHEN 'D' THEN 'Denied'
		--	WHEN 'P' THEN ''
		--	WHEN 'Z' THEN 'Not Known'
		--		END AS 'Coverage Result/Activity Status'
		--,REPLACE(REPLACE(FD.FILE_DISPOSITION_DESC,CHAR(10),''),CHAR(13),'') AS 'File Disposition'
		--,CM.SETTLEMENT_DATE AS 'Settlement Date'
		----,CASE ADL.SUIT_INDICATOR
		----	WHEN 'Y' THEN 'Yes'
		----	WHEN 'N' THEN 'No'
		----	ELSE NULL END AS 'Suit Indicator'
		--,CASE WHEN CM.FILE_TYPE = 'S' THEN 'Yes' Else NULL END AS 'In-Suit Indicator'
		--,REPLACE(REPLACE(ADL.ADDITIONAL_NOTES,CHAR(10),''),CHAR(13),'') AS 'Additional Notes'
		--,REPLACE(REPLACE(ADL.FILE_RESOLUTION,CHAR(10),''),CHAR(13),'') AS 'File Resolution'
		--,CD.FILE_SUFFIX_REFERENCE AS 'File Suffix'
		----,SR.ENTITY_IND
		----,SPEC.MM_SM_SPECIALTY_DESC
		----,CD.LINE_OF_BUSINESS
		----,CD.SUBRISK_ID_NUMBER
		--FROM [RAW_PROFIT].[PROFIT_SPIRIT].[CLAIMS_MASTER] CM
		--LEFT JOIN [RAW_PROFIT].[PROFIT_SPIRIT].[CLAIMS_DETAIL] CD
		--ON CD.FILE_NUMBER = CM.FILE_NUMBER
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.DEDUCTIBLE_RESOLUTIONS DR
		--ON DR.DEDUCTIBLE_RESOLUTION = CM.DEDUCTIBLE_RESOLUTION
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.CLAIM_HANDLER CH
		--ON CH.HANDLER_CODE = CM.HANDLER_CODE
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.ISSUING_COMPANIES COMP
		--ON COMP.ISSUING_COMPANY = CD.ISSUING_COMPANY
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.POLICIES PP
		--ON PP.POLICY_NUMBER = CD.POLICY_NUMBER AND PP.POLICY_INCEPTION_DATE = CD.POLICY_INCEPTION_DATE
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.POLICY_COVERAGES COV
		--ON COV.POLICY_NUMBER = CD.POLICY_NUMBER AND COV.POLICY_INCEPTION_DATE = CD.POLICY_INCEPTION_DATE AND COV.[COVERAGE_CODE] = CD.[COVERAGE_CODE] AND COV.[COVERAGE_INCEPTION_DATE] = CD.[COVERAGE_INCEPTION_DATE] 
		--AND COV.[SUBRISK_ID_NUMBER]  = CD.[SUBRISK_ID_NUMBER] AND COV.SEQ_NO = CD.FACL_SEQ
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.FILE_DISPOSITIONS FD
		--ON FD.FILE_DISPOSITION = CM.FILE_DISPOSITION
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.RISKS RSK
		--ON RSK.RISK_ID = CM.RISK_ID
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.CLAIMS_ADDITIONAL_INFO ADL
		--ON ADL.FILE_NUMBER = CM.FILE_NUMBER
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.UWAP_SUBRISKS SR
		--ON SR.RISK_ID = CM.RISK_ID AND SR.SUBRISK_ID_NUMBER = CD.SUBRISK_ID_NUMBER
		--LEFT JOIN RAW_PROFIT.PROFIT_SPIRIT.MM_SM_SPECIALTY SPEC
		--ON SPEC.MM_SM_SPECIALTY_CODE = SR.MM_MEDICAL_PHYSICIAN_SPECIALTY AND SPEC.LINE_OF_BUSINESS = CD.LINE_OF_BUSINESS
		--WHERE 
		--(CM.FILE_NUMBER LIKE 'SM%' OR CM.FILE_NUMBER LIKE 'MM%' OR CM.FILE_NUMBER LIKE 'LA%' OR CM.FILE_NUMBER LIKE 'DO%')
		) RESULTS