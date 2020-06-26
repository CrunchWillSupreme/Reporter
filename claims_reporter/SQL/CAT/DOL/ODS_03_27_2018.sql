select
    cat.CatastropheCode 'Catastrophe Code',
    cat.CatastropheYear 'Catastrophe Year',
    cat.CatastropheEventState As 'Catastrophe State',
    acc.AccidentStateAbbr As 'Claim Accident State',
    CASE le.LegalEntityName 
		WHEN 'Evanston Insurance Company' THEN 'Evanston Insurance Company (EIC)'
		WHEN 'Markel American Insurance Company' THEN 'Markel American Insurance Company (MAIC)'
		WHEN 'Markel Insurance Company' THEN 'Markel Insurance Company (MIC)' 
		--WHEN 'Essex Insurance Company' THEN 'Evanston Insurance Company (EIC)'  --Legal Entity simplification
		ELSE le.LegalEntityName
		END As 'Legal Entity',
    lt.LossTypeDescription As 'Loss Type',
    pl.ProductLineName As 'Product Line',
    pr.ProducerGeoRegionName As 'Region',
    ce.ClaimExaminerName As 'Claim Examiner',
    os.OriginatingSystemName As 'Source System',
    c.claimfoldernumber As 'Claim Number',
	'' AS 'CLM Count',
    CAST(ad.Date AS DATE) As 'Accident Date',
    CAST(rd.Date AS DATE) As 'Reported Date',
    CASE cs.ClaimStatusGroupDesc
		WHEN 'Void' THEN 'Closed'
		WHEN 'Record Only' THEN 'Open'
        WHEN 'Open For Recovery' THEN 'Open'
		ELSE cs.ClaimStatusGroupDesc
		END As 'Claim Status',
    case when c.ClaimCloseDateID <> -98 then CAST(cd.Date AS DATE) else NULL end As 'Closed Date',
	 pin.PrimaryInsuredName As 'Primary Insured Name',
    cl.ClaimantName 'Claimant Name',
	 c.PolicyNumber 'Policy Number',
	 -- FP.PolicyEffectiveDateID,
	 CAST(DD.Date AS DATE) AS 'Policy Effective Date',
	 -- FP.PolicyExpirationDateID,
	 --PED.DATE AS PolicyExpirationDate,
    SUBSTRING(io.zipofrisk, 1, 5) As 'Zip Code',
    io.uspsstatecpprovincecode As 'State',
    cty.countydesc as 'County',
    asl.ASLCode 'ASL Code',
    asl.ASLDescription 'ASL Description',
    p.ProductDescription 'Product Description',
    p.PerilDescription 'Peril Description',
    p.CoverageDesc 'Coverage Description',
 
    sum(c.lossreserveamt) As 'Loss Reserves',
    sum(c.losspaidamt) As 'Loss Paid',
    sum(c.expensereserveamt) As 'Expense Reserves',
    sum(c.expensepaidamt) As 'Expense Paid',
    sum(c.totalincurredamt) As 'Total Incurred (incl. ACR)',
	'' 'Additional Case Reserve (ACR)',
	sum(c.expensereserveamt) + sum(c.expensepaidamt) 'Total Expense',
	sum(c.totalincurredamt) As 'Total Calculated Incurred (incl. ACR)',
	sum(c.totalincurredamt) - sum(c.totalincurredamt) 'Differences',
	sum(c.lossreserveamt) + sum(c.losspaidamt) 'Case Incurred Loss',
	'' 'Open CLM Count',
	'' 'Closed CLM Count',
	'' 'CLMS Closed with Payment',
	'' 'CLMS Closed without Payment',
        CASE asl.ASLCode
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
        ELSE 'Unidentified'
		END AS "Category", 
	    '' AS 'Comments'

  
      from Markel_OperMart.fact.claim c
      inner join Markel_OperMart.dim.CatastropheEvent cat
        on c.CatastropheEventID = cat.CatastropheEventID
      inner join Markel_OperMart.dim.LegalEntity le
        on c.LegalEntityID = le.DimLegalEntityID
      inner join Markel_OperMart.dim.AccidentState acc  
        on c.AccidentStateID = acc.AccidentStateID
      inner join Markel_OperMart.dim.ClaimStatus cs
        on c.CurrentClaimStatusID = cs.ClaimStatusID
      inner join Markel_OperMart.dim.OriginatingSystem os
        on cs.OriginatingSystemID = os.ID  
      inner join Markel_OperMart.dim.Date ad
        on c.AccidentDateID = ad.DateID  
      inner join Markel_OperMart.dim.Date rd
        on c.ReportDateID = rd.DateID
      inner join Markel_OperMart.dim.Date cd
        on c.ClaimCloseDateID = cd.DateID  
      inner join Markel_OperMart.dim.ASL asl
        on c.ASLID = asl.ASLID  
      inner join Markel_OperMart.dim.ProductLine pl
        on c.ClaimProductLineID = pl.DimProductLineID  
      inner join Markel_OperMart.dim.ClaimExaminer ce
        on c.ExaminerID = ce.ClaimExaminerID
      inner join Markel_OperMart.dim.PrimaryInsuredName pin
        on c.InsuredNameID = pin.InsuredNameID
      inner join Markel_OperMart.dim.LossType lt 
        on c.LossTypeID = lt.DimLossTypeID
      inner join Markel_OperMart.dim.Product p
        on c.ProductID = p.DimProductID  
      inner join Markel_OperMart.dim.Producer pr
        on c.ProducerID = pr.DimProducerID
      inner join Markel_OperMart.dim.Claimant cl
        on c.ClaimantID = cl.DimClaimantID
      left outer join markel_ods.policy.insuredobjectperilcoverage iopc
        on c.insuredobjectperilcoverageid = iopc.insuredobjectperilcoverageid  
      left outer join markel_ods.insuredobject.insuredobject io
        on iopc.insuredobjectid = io.insuredobjectid  
      left outer join markel_ods.geography.county cty
        on cty.uspsstatecode = io.uspsstatecpprovincecode
          and cty.fipscountycode = io.countyofriskfipscode
  
    join Markel_OperMart.Dim.Date DD on c.PolicyEffectiveDateID = DD.DateID
    JOIN Markel_OperMart.Dim.Date PED on c.PolicyExpirationDateID = PED.DateID
   
    where 
	ad.Date = '2019-06-01' 
    and c.claimfeaturenumber is not null
    AND 
    (cat.CatastropheEventState = 'NM' OR
    acc.AccidentStateAbbr = 'NM')
    --and c.catastropheeventid not in (-98,-99)


    group by
    cat.CatastropheCode,
    cat.CatastropheYear,
    cat.CatastropheEventState,
    c.PolicyEffectiveDateID,
    DD.Date,
    c.PolicyExpirationDateID,
	PED.Date,
	acc.AccidentStateAbbr,
    le.LegalEntityName,
    lt.LossTypeDescription,
    pl.ProductLineName,
    pr.ProducerGeoRegionName,
    ce.ClaimExaminerName,
    os.OriginatingSystemName,
    c.claimfoldernumber,
    ad.Date,
    rd.Date,
    cs.ClaimStatusGroupDesc,
	c.ClaimCloseDateID,
	cd.Date,
    --case when c.ClaimCloseDateID <> -98 then cd.Date else NULL end,
    pin.PrimaryInsuredName,
    c.PolicyNumber,
    io.zipofrisk,
    io.uspsstatecpprovincecode,
    cty.countydesc,
    asl.ASLCode,
    asl.ASLDescription,
    p.ProductDescription,
    p.PerilDescription,
    p.CoverageDesc,
    cl.ClaimantName
    
	order by
    cat.CatastropheCode,
    cat.CatastropheYear,
    acc.AccidentStateAbbr,
	c.claimfoldernumber,
    le.LegalEntityName,
    lt.LossTypeDescription,
    pl.ProductLineName,
    pr.ProducerGeoRegionName,
    ce.ClaimExaminerName,
    os.OriginatingSystemName,
    ad.Date,
    rd.Date,
	cs.ClaimStatusGroupDesc,
    case when c.ClaimCloseDateID <> -98 then cd.Date else NULL end,
    pin.PrimaryInsuredName,
    c.PolicyNumber,
    io.zipofrisk,
    io.uspsstatecpprovincecode,
    cty.countydesc,
    asl.ASLCode,
    asl.ASLDescription,
    p.ProductDescription,
    p.PerilDescription,
    p.CoverageDesc,
    cl.ClaimantName