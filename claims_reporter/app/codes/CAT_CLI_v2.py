""" 
			CAT
			10/12/18
			Created by Will Han
            -Added company_type()
"""

import pyodbc, pandas as pd, datetime, json, argparse, sys, subprocess, win32com.client, datetime, os, smtplib
from openpyxl import load_workbook, Workbook
from openpyxl.styles import Font
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.base import MIMEBase
from email import encoders
from app.codes.quick_logger import QLogger
import ctypes

# GLOBAL LOG VARIABL
logger = QLogger.getInstance()

def main(email_user, email_pwd, sendmail=False):
    startTime = datetime.datetime.now()
    #constants
    d= datetime.date.today()
    month=str(d.strftime('%m'))
    day=str(d.strftime('%d'))
    year= str(d.year)
    today= year + '-' + month + '-' + day
    path = r'\\PATH\TO\FILES\CATReportTEMPLATEtest.xlsm'
    macro = 'Dump_Final.Dump_Final'
    saveas = r'\\PATH\TO\FILES\{year}\CAT\Reports\{today} - CAT Master Report.xlsx'.format(year=year, today=today)
    recipients = ['USER@EMAIL.com']
    cc = ['USER@EMAIL.com','USER@EMAIL.com']
    subject = f"CAT Master Report - {today}"
    body = "Hi USER,\n\nAttached you will find this week's CAT Master report.  It is also saved in the Ad Hoc Folder.\n\nThanks,\nWill Han"
    #Set up crap for the attachments
    attach = [r'\\PATH\TO\FILES\{year}\CAT\Reports\{today} - CAT Master Report.xlsx'.format(year=year, today=today)]
    CCONfile='CCON_05_24_2019.sql'
    ICONfile='ICON_05_24_2019.sql'
    MPLfile='MPL_05_24_2019.sql'
    ODSfile='ODS_03_27_2018.sql'
    Maverickfile='Maverick_01_23_2019.sql'
    DataLakeCNN = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=[SERVER_ADDRESS]')
    ClaimsCNN = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=[SERVER_ADDRESS]')
    OpermartCNN = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=[SERVER_ADDRESS]')
    ERMSCNN = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=[SERVER_ADDRESS]')
#    MPL_SP(ClaimsCNN)
    #run queries
    print('Beginning MPL CAT Query...')
    logger.new_record = 'Beginning MPL CAT Query...'        
    MPLBackup = queryDB(MPLfile,DataLakeCNN)    
    print('MPL CAT Query Complete!\nBeginning ICON CAT Query...') 
    ICONDF = queryDB(ICONfile,DataLakeCNN)    
    print('ICON CAT Query Complete!\nBeginning CCON CAT Query...')
    CCONDF = queryDB(CCONfile,DataLakeCNN)    
    print('CCON CAT Query Complete!\nBeginning ODS CAT Query...')
    ODSBackup = queryDB(ODSfile,OpermartCNN)    
    print('ODS CAT Query Complete!\nBeginning Maverick CAT Query')
    MaverickDF = queryDB(Maverickfile,DataLakeCNN)    
    EclipseBackup = Eclipse_prep()
    ERMSBackup = ERMSprep(ERMSCNN)
    
#    ERMSBackup = ERMSprep2()
    MPLDF, ODSDF, EclipseDF, ERMSDF = repl_legal_entity(MPLBackup, ODSBackup, EclipseBackup, ERMSBackup)
    combine_DF_and_csv(ICONDF, ODSDF, MPLDF, EclipseDF, ERMSDF, CCONDF, MaverickDF)   
    print('Adding MPL Company Types...')
    MPLBackup = company_type(MPLBackup)
    print('Adding ICON Company Types...')
    ICONDF = company_type(ICONDF)
    print('Adding CCON Company Types...')
    CCONDF = company_type(CCONDF)
    print('Adding ODS Company Types...')
    ODSBackup = company_type(ODSBackup)
    print('Adding Maverick Company Types...')
    MaverickDF = company_type(MaverickDF)
    print('Adding ERMS Company Types...')
    ERMSBackup = company_type(ERMSBackup)
    print('Adding Eclipse Company Types...')
    EclipseBackup = company_type(EclipseBackup)
   
    call_macro(path,macro,save_path=saveas)
    if sendmail:
#    for occur in rpts:
#        flag = False
#        while not flag:
#            try:
#                occur.send_email(email_user, email_pwd)
#                flag = True
#                print('Email Sent!')
#            except SMTPSenderRefused:
#                time.sleep(5)
        mail(recipients, cc, subject, body, attach, email_user, email_pwd)
    Mbox("Report Finished!","Your report has finished running!") 
    endTime = datetime.datetime.now()
    print('This script took ' + str(endTime - startTime) + ' minutes to complete!')

def queryDB(filename,CNN):
    with open(r'PATH\TO\FILES\%s' % filename) as f:
        query=f.read()
    dfName = pd.read_sql(query,CNN)
    return dfName
  
#def MPL_SP(ClaimsCNN):
#	print('Executing Stored Procedure for MPL CAT Pull...')
#	cursor = ClaimsCNN.cursor()
#	cursor.execute("exec LIVE.[dbo].[DATA_PULL_CAT2]")
#	cursor.commit()     
#	print('MPL CAT Pull Stored Procedure Complete!')  
#	return
	
def Eclipse_prep():
    print('Reading in Eclipse Data...')
    xls = pd.ExcelFile(r'\\PATH\TO\FILES\EFormatter.xlsx')
    EclipseBackup = pd.read_excel(xls, 'EclipseFormatter', skiprows = 0, na_filter=False) #read in Eclipse data
    print('Eclipse Data Read! \nRenaming Column...')
    EclipseBackup.rename(columns={'Total Incurred':'Total Incurred (incl. ACR)'}, inplace=True) #Rename column 
    print('Column Renamed! \nDeleting Unnecessary Columns...')
    EclipseBackup.drop(EclipseBackup.columns[[15, 17, 21, 28, 35]], axis=1, inplace=True) #axis: 0=row, 1=column. inplace=within dataframe
    EclipseBackup[['ASL Code']] = EclipseBackup[['ASL Code']].astype(str)
    print('Excess Columns Deleted!  \nAdding Remaining Columns With Calculations...')
    EclipseBackup["CLM Count"]=""  #add column
    EclipseBackup["Additional Case Reserve (ACR)"]=""
    EclipseBackup["Total Expense"]=EclipseBackup["Expense Reserves"] +EclipseBackup["Expense Paid"]
    EclipseBackup["Total Calculated Incurred (incl. ACR)"]=EclipseBackup["Total Incurred (incl. ACR)"].copy()
    EclipseBackup["Differences"]='0.00'
    EclipseBackup["Case Incurred Loss"]=EclipseBackup["Loss Reserves"]+EclipseBackup["Loss Paid"]
    EclipseBackup["Open CLM Count"]=""
    EclipseBackup["CLMS Open with Payment"]=""
    EclipseBackup["CLMS Open without Payment"]=""
    EclipseBackup["Closed CLM Count"]=""
    EclipseBackup["CLMS Closed with Payment"]=""
    EclipseBackup["CLMS Closed without Payment"]=""
    #EclipseDF["Category"]=""
    EclipseBackup["Comments"]=""
    EclipseBackup['Claim Sub-Status']=""
    EclipseBackup["Days to Close"]=""
    EclipseBackup["Policy Limit"]=""
    EclipseBackup["PL1"]=""
    EclipseBackup["PL2"]=""
    EclipseBackup["Coverage Total Limit"]=""
    EclipseBackup["Business Unit"]=""
    EclipseBackup["Total Loss"]=""
    EclipseBackup["Company Type"]=""
    EclipseBackup["Wholesale Producer Region"]=""
    print('Calculations complete! \nCreating ASL Dictionary...')
 
    ASLdict = {'ASL Code': [-99,-98,-97,-1,'',0,1,10,21,22,23,30,31,32,40,51,52,53,54,60,80,83,90,91,100,110,111,112,120,130,140,151,152,153,154,155,156,157,158,160,170,171,172,173,174,180,181,182,191,192,193,194,202,210,211,212,220,230,240,250,260,270,280,290,300,301,310,320,330,341,342,400,510,800,900,1200,1701,1702],
    			   'Category':['Unidentified'
                    ,'Unidentified'
                    ,'Unidentified'
                    ,'Unidentified'
                    ,'Unidentified'
                    ,'Unidentified'
                    ,'Other Liability'
                    ,'Fire'
                    ,'Allied Lines'
                    ,'Crop Multiple Peril'
                    ,'Federal Flood'
                    ,'Farmowners Multiple Peril'
                    ,'Farmowners Multiple Peril'
                    ,'Farmowners Multiple Peril'
                    ,'Homeowners Multiple Peril'
                    ,'Commercial Multiple Peril'
                    ,'Commercial Multiple Peril'
                    ,'Commercial Multiple Peril'
                    ,'Commercial Multiple Peril'
                    ,'Mortgage Guaranty'
                    ,'Ocean Marine'
                    ,'Ocean Marine'
                    ,'Inland Marine'
                    ,'Inland Marine'
                    ,'Financial Guaranty'
                    ,'Medical Malpractice'
                    ,'Medical Professional Liability - Occurrence'
                    ,'Medical Professional Liability - Claims Made'
                    ,'Earthquake'
                    ,'Group Accident and Health'
                    ,'Credit Accident and Health (Group and Individual)'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Other Accident and Health'
                    ,'Workers Compensation'
                    ,'Other Liability'
                    ,'Other Liability - Occurrence'
                    ,'Other Liability - Claims Made'
                    ,'Excess Workers Compensation'
                    ,'Other Liability'
                    ,'Products Liability'
                    ,'Products Liability - Occurrence'
                    ,'Products Liability - Claims Made'
                    ,'Private Passenger Auto Liability'
                    ,'Private Passenger Auto Liability'
                    ,'Commercial Auto Liability'
                    ,'Commercial Auto Liability'
                    ,'Commercial Auto Liability'
                    ,'Allied Lines'
                    ,'Private Passenger Auto'
                    ,'Auto Physical Damage'
                    ,'Aircraft (All Perils)'
                    ,'Fidelity'
                    ,'Surety'
                    ,'Allied Lines'
                    ,'Burglary and Theft'
                    ,'Boiler and Machinery'
                    ,'Credit'
                    ,'International'
                    ,'Warranty'
                    ,'Reinsurance - Non-Proportional Assumed Property'
                    ,'Reinsurance - Non-Proportional Assumed Property'
                    ,'Reinsurance - Non-Proportional Assumed Liability'
                    ,'Reinsurance - Non-Proportional Assumed Financial Lines'
                    ,'Tuition Reimbursement'
                    ,'Aggregate Write-in'
                    ,'Residential Property'
                    ,'Commercial Multiple Peril'
                    ,'Ocean Marine'
                    ,'Inland Marine'
                    ,'Commercial Property'
                    ,'General Liability'
                    ,'General Liability']
    			   }
    ASLDF = pd.DataFrame(data=ASLdict)
    ASLDF[['ASL Code']] = ASLDF[['ASL Code']].astype(str)
    print('Category Dictionary created! \nMatching ASL Code with Category...')
    EclipseBackup=EclipseBackup.merge(ASLDF, on='ASL Code', how='left')
    print('Merge Complete! \nRearranging columns...')
    EclipseBackup = EclipseBackup[['Catastrophe Code', 'Catastrophe Year', 'Catastrophe State', 'Claim Accident State', 'Legal Entity', 'Loss Type', 
    							 'Region', 'Claim Examiner', 'Source System', 'Claim Number', 'CLM Count', 'Accident Date', 'Reported Date', 
    							 'Claim Status', 'Claim Sub-Status', 'Closed Date', 'Days to Close', 'Primary Insured Name', 'Claimant Name', 'Wholesale Producer Region', 'Policy Number', 'Policy Effective Date',
    							 'Policy Limit', 'PL1', 'PL2', 'Coverage Total Limit', 'Zip Code', 'State', 'County', 'ASL Code', 'ASL Description', 'Business Unit', 'Product Line', 'Product Description', 'Peril Description', 'Coverage Description',
    							  'Loss Reserves', 'Loss Paid', 'Expense Reserves', 'Expense Paid', 'Total Incurred (incl. ACR)', 'Additional Case Reserve (ACR)',
    							 'Total Expense', 'Total Calculated Incurred (incl. ACR)', 'Differences', 'Case Incurred Loss', 'Open CLM Count', "CLMS Open with Payment", "CLMS Open without Payment", 'Closed CLM Count',
    							 'CLMS Closed with Payment', 'CLMS Closed without Payment', 'Total Loss', 'Category', 'Company Type', 'Comments']]
    print('Columns Rearranged')
    #Change NaT's to blank cells, then change dataype to string
    EclipseBackup['Closed Date'] = EclipseBackup['Closed Date'].fillna('')
    EclipseBackup['Closed Date'] = EclipseBackup['Closed Date'].astype(str)
    EclipseBackup['Accident Date'] = EclipseBackup['Accident Date'].fillna('')
    EclipseBackup['Accident Date'] = EclipseBackup['Accident Date'].astype(str)
    EclipseBackup['Reported Date'] = EclipseBackup['Reported Date'].fillna('')
    EclipseBackup['Reported Date'] = EclipseBackup['Reported Date'].astype(str)
    EclipseBackup['Policy Effective Date'] = EclipseBackup['Policy Effective Date'] .fillna('')
    EclipseBackup['Policy Effective Date'] = EclipseBackup['Policy Effective Date'].astype(str)
    ##substring date columns
    EclipseBackup['Closed Date'] = EclipseBackup['Closed Date'].str[: 10]
    #combinedDF['Closed Date'] = pd.to_datetime(combinedDF['Closed Date'], format="%m/%d/%Y")
    EclipseBackup['Accident Date'] = EclipseBackup['Accident Date'].str[: 10]
    #combinedDF['Accident Date'] = pd.to_datetime(combinedDF['Accident Date'], format="%m/%d/%Y")
    EclipseBackup['Reported Date'] = EclipseBackup['Reported Date'].str[: 10]
    #combinedDF['Reported Date'] = pd.to_datetime(combinedDF['Reported Date'], format="%m/%d/%Y")
    EclipseBackup['Policy Effective Date'] = EclipseBackup['Policy Effective Date'].str[: 10]
    #combinedDF['Policy Effective Date'] = pd.to_datetime(combinedDF['Policy Effective Date'], format="%m/%d/%Y")
    print('Formatting date columns complete! \nEclipse Dataframe Ready!')
    return EclipseBackup

def ERMSprep(ERMSCNN):
    cnn = ERMSCNN
    #cnn.autocommit=True
    
    cursor = cnn.cursor()
    print("Executing ERMSbase query...")
    cursor.execute(ERMSbase())
    print("Storing ERMS query results as pd.DF...")
    ERMSBackup = pd.read_sql_query(ERMSCAT(), cnn)
    ERMSBackup['Closed Date'] = ERMSBackup['Closed Date'].dt.strftime('%Y-%m-%d')
    ERMSBackup['Accident Date'] = ERMSBackup['Accident Date'].dt.strftime('%Y-%m-%d')
    ERMSBackup['Reported Date'] = ERMSBackup['Reported Date'].dt.strftime('%Y-%m-%d')
    ERMSBackup['Policy Effective Date'] = ERMSBackup['Policy Effective Date'].dt.strftime('%Y-%m-%d')
    ERMSBackup.replace(['NaT'], '', inplace=True)
    #print("ERMS results stored!")
    print('ERMS Dataframe Ready!')
    return ERMSBackup

def ERMSprep2():
    ERMSBackup = pd.read_excel(r'\\PATH\TO\FILES\ERMS Data 862019 (002).xlsx', header = 0)
    return ERMSBackup



def repl_legal_entity(MPLBackup, ODSBackup, EclipseBackup, ERMSBackup):
    print('Replacing ''Essex'' with ''EIC''...')
    MPLDF = MPLBackup.copy()
    MPLDF['Legal Entity'] = MPLDF['Legal Entity'].replace(['Evanston Insurance Company (EIC) formerly Essex'], 'Evanston Insurance Company (EIC)')
    print('Replacement Complete!\nReplacing ''Essex'' with ''EIC''...')
    ODSDF = ODSBackup.copy()
    ODSDF['Legal Entity'] = ODSDF['Legal Entity'].replace(['Essex Insurance Company'], 'Evanston Insurance Company (EIC)')
    print('Replacement Complete!\nReplacing ''3000'' and ''MICL'' with ''MIICL''...')
    EclipseDF = EclipseBackup.copy()
    EclipseDF['Legal Entity'] = EclipseDF['Legal Entity'].replace(['3000'], 'Markel Syndicate 3000 (MS3000)')
    EclipseDF['Legal Entity'] = EclipseDF['Legal Entity'].replace(['MICL'], 'Markel International Insurance Company Limited (MIICL)')
    EclipseDF['Legal Entity'] = EclipseDF['Legal Entity'].replace(['MAIC'], 'Markel American Insurance Company (MAIC)')
    EclipseDF['Legal Entity'] = EclipseDF['Legal Entity'].replace(['MISE'], 'Markel Insurance SE (MISE)')
    print('Replacement Complete!\nReplacing ''Ireland'' with ''MIICL''...')
    ERMSDF = ERMSBackup.copy()
    ERMSDF['Legal Entity'] = ERMSDF['Legal Entity'].replace(['Markel International Ireland'], 'Markel International Ireland (MIICL)')
    print('Replacement Complete!')
    return MPLDF, ODSDF, EclipseDF, ERMSDF

def combine_DF_and_csv(ICONDF, ODSDF, MPLDF, EclipseDF, ERMSDF, CCONDF, MaverickDF):
    print('Combining the DF"s...')
    ERMSDF = ERMSDF.drop(columns = ['FYI'], inplace=True, axis=1)
    combinedDF = pd.concat([ICONDF, ODSDF, MPLDF, EclipseDF, ERMSDF, CCONDF, MaverickDF], ignore_index=True)  ##Will need to add ERMS
    print('DF"s Combined!  \nRearranging columns to match template...')
    combinedDF = combinedDF[['Catastrophe Code', 'Catastrophe Year', 'Catastrophe State', 'Claim Accident State', 'Legal Entity', 'Loss Type', 
    					'Region', 'Claim Examiner', 'Source System', 'Claim Number', 'CLM Count', 'Accident Date', 'Reported Date', 
    					 'Claim Status', 'Closed Date', 'Days to Close', 'Primary Insured Name', 'Claimant Name', 'Wholesale Producer Region', 'Policy Number', 'Policy Effective Date',
    					 'Policy Limit', 'PL1', 'PL2', 'Coverage Total Limit', 'Zip Code', 'State', 'County', 'ASL Code', 'ASL Description', 'Business Unit', 'Product Line', 'Product Description', 'Peril Description', 'Coverage Description',
    					  'Loss Reserves', 'Loss Paid', 'Expense Reserves', 'Expense Paid', 'Total Incurred (incl. ACR)', 'Additional Case Reserve (ACR)',
    					 'Total Expense', 'Total Calculated Incurred (incl. ACR)', 'Differences', 'Case Incurred Loss', 'Open CLM Count', "CLMS Open with Payment", "CLMS Open without Payment", 'Closed CLM Count',
    					 'CLMS Closed with Payment', 'CLMS Closed without Payment', 'Total Loss', 'Category', 'Company Type', 'Comments']]
    print('Columns have been rearranged')
    ##substring date columns
    combinedDF['Closed Date'] = combinedDF['Closed Date'].str[: 10]
    #combinedDF['Closed Date'] = pd.to_datetime(combinedDF['Closed Date'], format="%m/%d/%Y")
    combinedDF['Accident Date'] = combinedDF['Accident Date'].str[: 10]
    #combinedDF['Accident Date'] = pd.to_datetime(combinedDF['Accident Date'], format="%m/%d/%Y")
    combinedDF['Reported Date'] = combinedDF['Reported Date'].str[: 10]
    #combinedDF['Reported Date'] = pd.to_datetime(combinedDF['Reported Date'], format="%m/%d/%Y")
    combinedDF['Policy Effective Date'] = combinedDF['Policy Effective Date'].str[: 10]
    #combinedDF['Policy Effective Date'] = pd.to_datetime(combinedDF['Policy Effective Date'], format="%m/%d/%Y")
    print('Formatting date columns complete!')
    #MPLDF.columns.tolist()
	######################################################
	###-*-*-*-*- WRITE TO CSV -*-*-*-*-###
	######################################################
    print('Writing to CSV''s...')
    combinedDF.to_csv(r'\\PATH\TO\FILES\combined.csv', header=False, index=False)
    ICONDF.to_csv(r'\\PATH\TO\FILES\ICONBackup.csv', header=False, index=False)
    CCONDF.to_csv(r'\\PATH\TO\FILES\CCONBackup.csv', header=False, index=False)
    MPLDF.to_csv(r'\\PATH\TO\FILES\MPLBackup.csv', header=False, index=False)
    ODSDF.to_csv(r'\\PATH\TO\FILES\ODSBackup.csv', header=False, index=False)
    EclipseDF.to_csv(r'\\PATH\TO\FILES\EclipseBackup.csv', header=False, index=False)
    ERMSDF.to_csv(r'\\PATH\TO\FILES\ERMSBackup.csv', header=False, index=False)
    MaverickDF.to_csv(r'\\PATH\TO\FILES\MaverickBackup.csv', header=False, index=False)
    print('Writing to CSV''s complete!')
    return


######################################################
###-*-*-*-*- RUN FINAL DUMP MACRO -*-*-*-*-###
######################################################




def call_macro(wb_path, macro_name,*args, save_path = None):
    """
    Opens an excel workbook wb_path, calls its macro_name method with
    parameters *args. Optionally saves to save_path.

    Parameters:
    -----
    wb_path str:
    path to excel xlsm workbook containing macro

    macro_name str:
    module and function/subroutine to invoke

    *args tuple:
    tuple of positional arguments to pass to the excel macro

    save_path str:
    path and name to save workbook as after running the macro
    """
    #grab excel application
    xl = win32com.client.Dispatch("Excel.Application")
    print(f'loaded excel as "{xl}".')
    #grab actual workbook
    wb = xl.Workbooks.Open(Filename=wb_path)
    
    print(f'loaded workbook as "{wb.Name}"')
    #call macro from workbook
    print(f'calling {wb.Name}!{macro_name}...',*args)
    if any(args):
        xl.Application.Run(f'{wb.Name}!{macro_name}',*args)
    else:
        xl.Application.Run(f'{wb.Name}!{macro_name}')
        
    #save at save_path, or over the original if save_path not specified
    print('saving')
    if save_path is not None:
         xl.Application.Run(f'{wb.Name}!Savexlsx', save_path)

    #cleanup
    print('quitting')
    xl.Application.DisplayAlerts = False
    xl.Application.Quit()  

#Create Module
def mail(to, cc, subject, text, attach, email_user, email_pwd):
   print("Assigning Sender, Recipient(s), and Subject of email...")
   msg = MIMEMultipart()
   msg['From'] = email_user
   msg['To'] = ", ".join(to)
   msg['CC'] = ", ".join(cc)
   bcc=['USER@EMAIL.com']
   cc = ['USER@EMAIL.com','USER@EMAIL.com']
   msg['Subject'] = subject
   print('Adding body of message...')
   msg.attach(MIMEText(text))
   print('Formatting attachments...')
   #get all the attachments
   for file in attach:
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
   mailServer.sendmail(email_user, to+cc+bcc, msg.as_string())
   # Should be mailServer.quit(), but that crashes...
   mailServer.close()
   print('Email Sent!')

def ERMSbase():
    with open(r'\\PATH\TO\FILES\ERMStemp.sql') as t:
        temp = t.read()
    return temp

def ERMSCAT():
    with open(r'\\PATH\TO\FILES\ERMSfinal.sql') as f:
        final = f.read()
    return final

def Mbox(title, text):
    return ctypes.windll.user32.MessageBoxW(0, text, title, 0)

def company_type(df):
    company_types = {"Atlantic Specialty Insurance Company (Atlantic Specialty)": "Reinsurer",
                    "Essentia Insurance Company (Essentia)": "Admitted Company",
                    "Evanston Insurance Company (EIC)": "Surplus Lines",
                    "FirstComp Insurance Company (FCIC)": "Admitted Company",
                    "Markel American Insurance Company (MAIC)": "Admitted Company",
                    "Markel Bermuda Limited (MBL)": "Reinsurer",
                    "Markel Global Reinsurance Company (MGRC)": "Reinsurer",
                    "Markel Insurance Company (MIC)": "Admitted Company",
                    "Markel Insurance SE (MISE)": "Reinsurer and Surplus Lines in the U.S.",
                    "Markel International Insurance Company Limited (MIICL)": "Reinsurer and Surplus Lines in the U.S.",
                    "Markel International Ireland (MIICL)": "Reinsurer and Surplus Lines in the U.S.",
                    "Markel Syndicate 3000 (MS3000)": "Reinsurer and Surplus Lines in the U.S.",
                    "Nationwide Mutual Insurance Company (Nationwide)": "Reinsurer",
                    "Pinnacle National Insurance Company (PNIC)": "Admitted Company",
                    "United Specialty Insurance Company (United Specialty) [Non-fin]": "Reinsurer"}
    df['Company Type'] = df['Legal Entity'].map(company_types)
    return df

if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv)
    parser.add_argument('-e', type = str, help = 'your outlook email address')
    parser.add_argument('-p', type = str, help = 'your outlook email password (same as your VDI password)')
    parser.add_argument('--creds', type = str, help = 'the path to your credentials file')
    args = parser.args()
    if (args.e and args.p):
        main(args.e, args.p)
#    elif (args.creds):
#        with open(args.creds) as c:
#            creds = c.read()
#            email = creds['c1']
#            pw = creds['c2']
#            main(email, pw)
    else:
        raise Exception('Input either your email address and password OR the path to your config file')
	
	
	
