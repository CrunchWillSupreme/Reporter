""" 
			Profit and Primis Open and Closed Claims CLI
			10/11/18
			Created by Will Han
"""

import pyodbc, pandas as pd, datetime as dt, os, json, smtplib, argparse, sys, time
from openpyxl import load_workbook, Workbook
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from smtplib import SMTPSenderRefused

def main(email_user, email_pwd, datestring, sendmail:bool=False):
    schedule = get_json()
    d_string = date_format(datestring)
    start_date, end_date = get_open_and_closed_dates(schedule, dates_for=d_string)
#    tempquery = tempQuery()
#    finalquery = finalQuery(start_date, end_date)
    source = 'Profit and Primis'
    #	temp = tempquery
    #	final = finalquery
    temp, finalquery = read_queries(start_date, end_date)
    runqueryandexcel(source, temp, finalquery, end_date)
    if sendmail:
        flag = False
        while not flag:
            try:    
                recipients = ['brandon.arnold@markel.com']
                subject = "Profit & Primis Open and Closed Claim Report"
                body = "Hello Brandon,\n\nAttached you will find the Profit & Primis Opened and Closed Claims Report for {end_date:%B %Y}.  Please let me know if you have any questions.\n\nThanks,\nWill Han".format(end_date=end_date)
                ppattach = [r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Compliance\Profit & Primis Opened and Closed Claim Report - {end_date:%B %Y}.xlsx'.format(end_date=end_date)]
                email( recipients, subject, body, ppattach, email_user, email_pwd)
                print('Email Sent!')
                flag = True
            except SMTPSenderRefused:
                time.sleep(5)
	
def get_json():
	with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\Files\schedule.json') as f:
		schedule = json.loads(f.read())
	return schedule
	
def get_open_and_closed_dates(schedule, dates_for=dt.date.today()):
    month = str(dates_for.month)
    year = str(dates_for.year)
    start_date = dt.datetime.strptime(schedule[year][month]['start_date'],'%m/%d/%Y')
    end_date = dt.datetime.strptime(schedule[year][month]['end_date'],'%m/%d/%Y')
    return start_date, end_date

def read_queries(start_date, end_date):
    with open(r'P:\GitHub\claims_reporter\app\codes\SQL\ProfitPrimis\results_temp.sql') as r:
        temp = r.read()
    with open(r'P:\GitHub\claims_reporter\app\codes\SQL\ProfitPrimis\final_query.sql') as f:
        finalquery = f.read().format(start_date=start_date, end_date=end_date)
    return temp, finalquery
	
def runqueryandexcel(source, temp, finalquery, end_date):
    #Create Connection
    print('Creating server connection...')
    DataLakeserver = 'VA1-PCORSQL210,21644'
    driver = '{SQL Server}'    # Driver you need to connect to the database
    port = '1433'
    DataLakecnn = pyodbc.connect('DRIVER='+driver+';PORT='+port+';SERVER='+DataLakeserver)
    DataLakecnn.autocommit=True
    cursor=DataLakecnn.cursor()
    print("Executing "+source+" query...")
    cursor.execute(temp)
    print("Storing "+source+" query results as pd.DF...")
    output = pd.read_sql_query(finalquery, DataLakecnn)
    print(source + " results stored!")                               
    rngoutput = output.values.tolist()
    print('Sheet added!\nRetrieving TEMPLATE workbook')
    wb = load_workbook(r"\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\TEMPLATES\TEMPLATE - ProfitPrimisOpenedClosedClaim.xlsx")
    print("TEMPLATE workbook retrieved! \nPasting "+source+" output onto Excel sheet..")
    ws=wb.get_sheet_by_name('Sheet1')
    for row_num, row in enumerate(rngoutput):
        for col_num,val in enumerate(row):
            ws.cell(row=row_num+2,column=col_num+1).value=val #python is zero-indexed, openpyxl is 1-indexed
    print(source+" output pasted onto sheet!")                    
    print('Sheet name updated! \nSaving workbook...')
    wb.save(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Compliance\Profit & Primis Opened and Closed Claim Report - {end_date:%B %Y}.xlsx'.format(end_date=end_date))
    print('Workbook Saved!')
    return

def email(to, subject, text, ppattach, email_user, email_pwd, cc=None):
    print('Assigning Sender, Recipient(s), and Subject of email...')
    msg = MIMEMultipart()
    msg['From'] = email_user
    msg['To'] = ", ".join(to)
    bcc = ['whan@markelcorp.com']
    msg['Subject'] = subject
    print('Adding body of message...')
    msg.attach(MIMEText(text))
    print('Formatting attachments...')
    for file in ppattach:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(open(file, 'rb').read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(file))
        msg.attach(part)
        print('Setting up server...')   
        mailServer = smtplib.SMTP('outlook.markelcorp.com', 587)
        mailServer.ehlo()
        mailServer.starttls()
        mailServer.ehlo()
        mailServer.login(email_user, email_pwd)
        mailServer.sendmail(email_user, to+bcc, msg.as_string())
        # Should be mailServer.quit(), but that crashes...
        mailServer.close()
        print('Email Sent!')
      
def date_format(datestring):
    x = datestring
    x = dt.datetime.strptime(x, '%m/%Y')
    return x
		
#def finalQuery(start_date, end_date):
#    return """SELECT * FROM ##TEMP_RESULTS
#    WHERE 
#    ([Claim Feature Closed Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}' OR [Claim Folder Closed Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}')
#    
#    OR
#    ([Claim Feature Opened Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}' OR [Claim Folder Opened Date] BETWEEN '{start_date:%Y-%m-%d}' AND '{end_date:%Y-%m-%d}')
#      
#    OR [ITD Expense] > 0
#    OR (
#    ([Folder Status] NOT IN ('Closed', 'Void') AND [State Report Indicator] IS NOT NULL) OR ([Feature Status] NOT IN ('Closed', 'Void') AND [State Report Indicator] IS NOT NULL)
#    )
#    OR (
#    ([Folder Status] NOT IN ('Closed', 'Void') AND [NPDB Report Indicator] IS NOT NULL) OR ([Feature Status] NOT IN ('Closed', 'Void') AND [NPDB Report Indicator] IS NOT NULL)
#    )
#    
#    ORDER BY [Legacy System], [Claim Number] asc
#    """.format(start_date=start_date, end_date=end_date)
#
#def tempQuery():
#	return """IF OBJECT_ID('tempdb..##TEMP_RESULTS') IS NOT NULL DROP TABLE ##TEMP_RESULTS
#		SELECT * 
#		INTO ##TEMP_RESULTS
#		FROM (
#		select DISTINCT
#		'PRIMIS' AS 'Legacy System'
#		,ADJ.B27_NAME1 AS 'Examiner Name'
#		,AT.D76_DESCRIPTION AS 'File Type'
#		,CC.B69_CLAIM_OCCUR AS 'Claim Number'
#		,CC.D87_ACC_STATE AS 'Loss State'
#		,CASE CC.STATE_REPORTING
#			WHEN '1' THEN 'Yes'
#			WHEN  '2' THEN 'No'
#				ELSE NULL END AS 'State Report Indicator'
#		,CASE CC.NPDB_REPORTING
#			WHEN '1' THEN 'Yes'
#			WHEN '2' THEN 'No'
#				ELSE NULL END AS 'NPDB Report Indicator'
#		,CASE CC.E87_STATUS 
#			WHEN 0 THEN 'Open'
#			WHEN 1 THEN 'New'
#			WHEN 2 THEN 'Closed'
#			WHEN 3 THEN 'Open for Recovery'
#			WHEN 4 THEN 'Void' ELSE CAST(CC.E87_STATUS AS varchar) END AS 'Folder Status'
#		,CR.[F04_DI_LOSS_PAID] AS 'ITD Loss'
#		,CASE WHEN CR.B69_CLAIM_OCCUR IS NULL THEN NULL ELSE CONCAT(CR.B69_CLAIM_OCCUR,'-',CR.U10_CLMNUM) END AS 'Claim Feature Number'
#		,NA1.B27_NAME1 AS 'Issuing Company'
#		,CONCAT(CC.A00_PNUM,'-',CC.A06_EDITION) AS 'Policy Number/Edition'
#		,CR.C07_LIMIT_3 AS 'Occurrence Limit'
#		,CR.B85_DED_AMT AS 'Deductible'
#		,NA2.B27_NAME1 AS 'Insured Name'
#		,NA2.B28_ADDR1 AS 'Insured Address 1'
#		,NA2.B28_ADDR2 AS 'Insured Address 2'
#		,NA2.B30_CITY AS 'Insured City'
#		,NA2.B31_STATE AS 'Insured State'
#		,NA2.B32_ZIP AS 'Insured Zip'
#		,PC.A02_RATING_STATE AS 'Risk State'
#		,CLMT.B27_NAME1 AS 'Claimant Name'
#		,CONCAT(CLMT.B28_ADDR1,' ',CLMT.B28_ADDR2) AS 'Claimant Address'
#		,CLMT.B30_CITY AS 'Claimant City'
#		,CLMT.B31_STATE AS 'Claimant State'
#		,CLMT.B32_ZIP AS 'Claimant Zip'
#		,CC.B70_LOSS_DATE AS 'Loss Date'
#		,CC.G36_CLAIMS_MADE AS 'Claims Made Date'
#		,CC.D43_REPORTED_DATE AS 'Reported Date'
#		,CC.H53_NDATE AS 'Claim Folder Opened Date'
#		,CASE WHEN CC.E87_STATUS = 3 THEN CC.E87_STATUS_DATE END AS 'Claim Folder Re-Opened Date'
#		,CASE WHEN CC.E87_STATUS = 2 THEN CC.E87_STATUS_DATE END AS 'Claim Folder Closed Date'
#		,CR.H53_NDATE AS 'Claim Feature Opened Date'
#		,CASE WHEN CR.E87_STATUS = 2 THEN CR.E87_STATUS_DATE END AS 'Claim Feature Closed Date'
#		,CC.[ERROR_BEGIN_DATE] AS 'Error Begin Date'
#		,CC.[ERROR_END_DATE] AS 'Error End Date'
#		,CASE CR.E87_STATUS 
#			WHEN 0 THEN 'Open'
#			WHEN 1 THEN 'New'
#			WHEN 2 THEN 'Closed'
#			WHEN 3 THEN 'Open for Recovery'
#			WHEN 4 THEN 'Void' ELSE CAST(CR.E87_STATUS AS varchar) END AS 'Feature Status'
#		,CLASS.B83_DESCRIPTION AS 'Prof. Activity of Insured'
#		,CR.[F09_DI_EXP_PAID] AS 'ITD Expense'
#		,CR.E93_DI_LOSS AS 'Outstanding Loss Reserve'
#		,CR.E99_DI_EXP AS 'Outstanding Expense Reserve'
#		,CC.ACTIVITY_DESC AS 'Coverage Result/Activity Status'
#		,FD.FILE_DISPOSITION_VALUE AS 'File Disposition'
#		,'' AS 'Settlement Date'
#		,CASE 
#			WHEN CC.D76_ACTIVITY_TYPE = 'U' THEN 'Yes'
#			WHEN CC.A13_ACT_STATUS = 'IS' THEN 'Yes'
#			ELSE NULL END AS 'In-Suit Indicator'
#
#		,NULL AS 'Additional Notes'
#		,NULL AS 'File Resolution'
#		,NULL AS 'File Suffix'
#		from RAW_PRIMIS.PRIMIS2.CCOMMON CC
#		left join RAW_PRIMIS.PRIMIS2.CRESERVE CR
#		ON CR.B69_CLAIM_OCCUR = CC.B69_CLAIM_OCCUR
#		left join RAW_PRIMIS.PRIMIS2.PCOMMON PC
#		ON PC.A00_PNUM = CC.A00_PNUM AND PC.A06_EDITION = CC.A06_EDITION
#		left join RAW_PRIMIS.PRIMIS2.PCOVERAGE COV
#		ON COV.A00_PNUM = PC.A00_PNUM AND COV.A06_EDITION = PC.A06_EDITION AND COV.B79_UNIT = CR.B79_UNIT AND COV.C87_COVERAGE = CR.C87_COVERAGE
#		left join RAW_PRIMIS.PRIMIS2.PUNIT PU
#		ON PU.A00_PNUM = PC.A00_PNUM AND PU.A06_EDITION = PC.A06_EDITION AND PU.B79_UNIT = CR.B79_UNIT
#		left join RAW_PRIMIS.PRIMIS2.COMPANY CP
#		ON CP.A01_COMPANY = CC.A01_COMPANY
#		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS NA1
#		ON NA1.E04_ORIGNUM = CP.E04_NAMENUM AND NA1.E04_NEXT IS NULL
#		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS NA2
#		ON NA2.E04_ORIGNUM = PC.E04_INS_ORIGNUM AND NA2.E04_NEXT IS NULL
#		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS ADJ
#		ON ADJ.E04_ORIGNUM = CC.R30_IN_HOUSE_ADJ AND ADJ.E04_NEXT IS NULL
#		left join RAW_PRIMIS.PRIMIS2.NAME_ADDRESS CLMT
#		ON CLMT.E04_ORIGNUM = CR.E04_CLAIMANT_NUM AND CLMT.E04_NEXT IS NULL
#		left join RAW_PRIMIS.PRIMIS2.LQ70_UNDERWRITER UW
#		ON UW.Q70_UNDERWRITER = PC.Q70_UNDERWRITER
#		left join RAW_PRIMIS.PRIMIS2.LB84_DED_TYPE DED
#		ON DED.B84_DED_TYPE = COV.B84_DED_TYPE
#		left join RAW_PRIMIS.PRIMIS2.LD76_ACTIVITY_TYPE AT
#		ON AT.D76_ACTIVITY_TYPE = CC.D76_ACTIVITY_TYPE
#		left join RAW_PRIMIS.PRIMIS2.LB83_CLASS_CODES CLASS
#		ON CLASS.B83_CLASS = CR.B83_CLASS AND CLASS.B97_SUBLINE = CR.B97_SBL
#		left join RAW_PRIMIS.PRIMIS2.FILE_DISPOSITION FD
#		ON FD.FILE_DISPOSITION_ID = CC.FILE_DISPOSITION_ID
#		WHERE 
#		CC.B69_CLAIM_OCCUR LIKE 'SM%' OR CC.B69_CLAIM_OCCUR LIKE 'MM%' OR CC.B69_CLAIM_OCCUR LIKE 'LA%' OR CC.B69_CLAIM_OCCUR LIKE 'DO%'
#
#		
#		) RESULTS
#		"""



if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv)
    parser.add_argument('-e', type = str, help = 'your outlook email address')
    parser.add_argument('-p', type = str, help = 'your outlook email password (same as your VDI password)')
    parser.add_argument('-d', type = str, help = 'start date (month/year)')
    parser.add_argument('--creds', type = str, help = 'the path to your credentials file')
    args = parser.args()
    if (args.e and args.p and args.d):
        main(args.e, args.p, args.d)
    elif (args.creds):
        with open(args.creds) as c:
            creds = json.loads(c.read())
        email = creds['c1']
        pw = creds['c2']
        main(email, pw)
    else:
        raise Exception('Input either your email address and password OR the path to your config file')
	
	
	
	
	
	