						
							
SELECT	
    ICO.ICO_PCSCATNumber AS 'Catastrophe Code'
    ,YEAR(CONVERT(VARCHAR(4),ICO.ICO_OccurrenceDateTime,120)) AS 'Catastrophe Year'
    ,ipi.IPI_PredominantState AS 'Catastrophe State'
    ,ipi.IPI_PredominantState AS 'Claim Accident State'
    ,'FirstComp Insurance Company (FCIC)' AS 'Legal Entity'
    ,'' AS 'Loss Type'
    ,ISNULL(lt.LT_CoverageType,'Property') AS 'Product Line' --check this
    ,'' AS 'Wholesale Producer Region'
    ,ISNULL(PER.PE_FirstName + ' ' + PER.PE_LastName,'') AS 'Claim Examiner'
    ,'Maverick' AS 'Source System'
	,IC.IC_ClaimNumber AS 'Claim Number'
    ,'' AS 'CLM Count'
    ,CONVERT(VARCHAR(10),ICO.ICO_OccurrenceDateTime,120) AS 'Accident Date'
    ,CONVERT(VARCHAR(10),ISNULL(ICO.ICO_CarrierNotifiedDate, IC.IC_CarrierReportedDate),120) AS 'Reported Date'	
	,CASE WHEN cs.CS_ClaimStatus = 'Re-Closed' THEN 'Closed'
    ELSE cs.CS_ClaimStatus END AS 'Claim Status'
    ,ISNULL(CONVERT(VARCHAR(10),ics2.ICS_DateTime,120),'') AS 'Closed Date'
    ,ii.II_InsuredName AS 'Primary Insured Name'
    ,'' AS 'Claimant Name'
	,ipi.IPI_PolicyNumber AS 'Policy Number'
	--,ISNULL(CONVERT(VARCHAR(10),ics.ICS_DateTime,120),'') AS [Active_Status_Date]	
    ,'' AS 'Policy Effective Date'
    ,'' AS 'Zip Code'
    ,'' AS 'State'
    ,'' AS 'County'
    ,'' AS 'ASL Code'
    ,'' AS 'ASL Description'
    ,ISNULL(lt.LT_CoverageType,'Property') AS 'Product Description' --check this	
    ,'' AS 'Peril Description'
    ,'Business Owners Policy (BOP)' AS 'Policy Coverage Description'				
	--,SUM(ISNULL(ira.IRA_AmountReserved,0)) AS [Total_Incurred]      						
	--,SUM(ISNULL(ira.IRA_AmountPaid,0)) AS [Total_Paid]  						
	--,SUM(ISNULL(ira.IRA_AmountDeductible,0)) AS [Total_Deductible] 
    ,SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) 						
		ELSE 0 END) AS 'Loss Reserve'					
	,SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0)						
		ELSE 0 END) AS 'Loss Paid'	 						
	,SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) 						
		ELSE 0 END) AS 'Expense Reserve'					
	,SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0)						
		ELSE 0 END) AS 'Expense Paid'	
    ,(SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END) 
        +SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END))
        AS 'Total Incurred (incl. ACR)'
    ,'' AS 'Additional Case Reserve (ACR)'
    ,(SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END)
        + SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0)	ELSE 0 END))
        AS 'Total Expense'
    ,(SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END) 
        +SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END))
        AS 'Total Calculated Incurred (incl. ACR)'
    ,(SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END) 
        +SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END))
        -(SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END) 
        +SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END)
        +SUM(CASE WHEN RT.RT_ReserveType = 'Expense' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END)) 
        AS 'Differences'
    ,(SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.ira_amountOutstanding,0) ELSE 0 END) 					
	    +SUM(CASE WHEN RT.RT_ReserveType = 'Indemnity' OR RT.RT_ReserveType = 'Property' THEN ISNULL(IRA.IRA_AmountPaid,0) ELSE 0 END))
        AS 'Case Incurred Loss'
    ,'' AS 'Open CLM Count'
    ,'' AS 'Closed CLM Count'
    ,'' AS 'CLMS Closed with Payment'
    ,'' AS 'CLMS Closed without Payment'
    ,'Unidentified' AS 'Category'
    ,'' AS 'Comments'
FROM [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredClaims_IC] ic							
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Performers] per							
	ON per.PE_ID = ic.IC_AdjusterID						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredPricingInfo_IPI] IPI							
	ON IPI.IPI_ID = ic.IC_IPI_ID						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Claim_reference_Status_CS] cs							
	ON cs.CS_ID = ic.IC_ClaimStatus						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Claim_reference_Type_CT] ct							
	ON ct.CT_ID = ic.IC_ClaimType						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Claim_reference_LossType_LT] lt							
	ON lt.LT_ID = ic.IC_LossType						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredReserveHistory_IRH] IRH							
	ON IRH.IRH_IC_ID = ic.IC_ID						
	AND IRH.IRH_Active = 1						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredReserveAmounts_IRA] IRA							
	ON IRA.IRA_IRH_ID = irh.IRH_ID						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Claim_reference_SubReserveType_SRT] SRT							
	ON SRT.SRT_ID = IRA.IRA_SRT_ID    						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[Claim_reference_ReserveType_RT] RT							
	ON RT.RT_ID = SRT.SRT_RT_ID 						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredClaimOccurrence_ICO] ICO							
	ON ICO.ICO_ID = IC.IC_ICO_ID						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredClaimStatus_ICS]ics							
	ON ics.ICS_ClaimID = ic.IC_ID						
	AND ics.ICS_ActiveFlag = 1  						
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredClaimStatus_ICS] ics2							
	ON ICS2.ICS_ID =	(					
						SELECT TOP 1 t.ICS_ID	
						FROM [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredClaimStatus_ICS] t	
						WHERE t.ICS_ClaimID = IC.IC_ID	
							AND t.ICS_CS_ID = '15'
						ORDER BY t.ICS_DateTime DESC	
						)	
LEFT JOIN [RAW_MAVERICK_1stcomp].[dbo].[policy_InsuredInfo_II] ii							
	ON ii.II_ID = ipi.IPI_II_ID						
WHERE IPI.IPI_PL_ID = '2'
--AND ICO.ICO_PCSCATNumber IS NOT NULL
--AND YEAR(CONVERT(VARCHAR(4),ICO.ICO_OccurrenceDateTime,120)) >= 2016
AND ICO.ICO_OccurrenceDateTime BETWEEN '2019-05-18' AND '2019-05-24'
--AND ipi.IPI_PredominantState = 'NM'
GROUP BY							
	IC.IC_ClaimNumber						
	,ipi.IPI_PolicyNumber						
	,ii.II_InsuredName						
	,ISNULL(PER.PE_FirstName + ' ' + PER.PE_LastName,'')						
	,ipi.IPI_PredominantState						
	,CONVERT(VARCHAR(10),ICO.ICO_OccurrenceDateTime,120)
    ,ICO.ICO_OccurrenceDateTime
	,CONVERT(VARCHAR(10),ISNULL(ICO.ICO_CarrierNotifiedDate, IC.IC_CarrierReportedDate),120)						
	,cs.CS_ClaimStatus						
	,ISNULL(CONVERT(VARCHAR(10),ics.ICS_DateTime,120),'')						
	,ISNULL(CONVERT(VARCHAR(10),ics2.ICS_DateTime,120),'')						
	,ISNULL(lt.LT_CoverageType,'Property')						
	,ICO.ICO_PCSCATNumber
