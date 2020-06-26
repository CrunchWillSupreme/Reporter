SELECT * FROM ##TEMP_RESULTS
WHERE 
([Claim Feature Closed Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}' OR [Claim Folder Closed Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}')

OR
([Claim Feature Opened Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}' OR [Claim Folder Opened Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}')

--OR [ITD Expense] > 0
OR (
([Folder Status] NOT IN ('Closed', 'Void') AND [State Report Indicator] IS NOT NULL) OR ([Feature Status] NOT IN ('Closed', 'Void') AND [State Report Indicator] IS NOT NULL)
)
OR (
([Folder Status] NOT IN ('Closed', 'Void') AND [NPDB Report Indicator] IS NOT NULL) OR ([Feature Status] NOT IN ('Closed', 'Void') AND [NPDB Report Indicator] IS NOT NULL)
)

ORDER BY [Legacy System], [Claim Number] asc