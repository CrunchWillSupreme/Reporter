""" 
			IGTC CLI
			10/11/18
			Created by Will Han
"""

import datetime, json, pandas as pd, pyodbc, cx_Oracle, win32com.client, os, smtplib, argparse, sys
from openpyxl import load_workbook
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

def main(email_user, email_pwd, datestring, sendmail:bool=False):
    creds, schedule, PgmYr, icon, recon = get_files()
    d_string = date_format(datestring)
    start_date, end_date = get_open_and_closed_dates(schedule, dates_for = d_string)
    create_folder(end_date)
    today = datetime.date.today()
    convert_date_type(PgmYr)
    Query_and_csv(recon, icon, end_date, PgmYr)
    #set up parameters for Macro function
    path = r"\PATH\TO\FILES\TEMPLATEIGTCReportICONRECONITD.xlsm"
    macro = 'IGTC.IGTC'
    saveas = r'\\PATH\TO\FILES\{end_date:%Y}\{end_date:%m%Y}\IGTC Report - ICONRECON - ITD_{end_date:%m%Y}.xlsx'.format(end_date=end_date)
    #run Macro function
    call_macro(path,macro,save_path=saveas)
    if sendmail:
        #set up parameters for email function
        recipients = ['USER@EMAIL.com',]
        #cc = ['USER@EMAIL.com']
        subject = "IGTC - Monthly Loss Report - {end_date:%B %Y}".format(end_date=end_date)
        body = "Hello USER,\n\nAttached you will find the IGTC - Monthly Loss Report as of {end_date:%m/%d/%Y}.  \n\nPlease follow the link, familiarize yourself with the webpage and bookmark it for your convenience.  Your report will be listed under the Monthly Reports tab.\nLink: http://mymarkelglobal/Departments/Claims/northamericaandbermuda/Pages/Metrics.aspx\n\nPlease let me know if there are any questions.\n\nThanks,\nWill Han".format(end_date=end_date)
        attach = [saveas]
        #run email function
        mail(recipients, subject, body, attach, email_user, email_pwd)
    print('Report has finished!')
        

###############################################################################
#################### READ IN CONFIG FILES AND SQL FILES #######################
###############################################################################
def get_files() -> tuple:
	with open(r'PATH\TO\FILES\credentials.json') as c:
		creds = json.loads(c.read())
	with open(r'\\PATH\TO\FILES\schedule.json') as f:
		schedule = json.loads(f.read())
	with open(r"\\PATH\TO\FILES\pgmYR.json") as p:
		PgmYr = json.loads(p.read())
	with open(r"\\PATH\TO\FILES\ICON-IGTC_Report-ITD.sql") as i:
		icon = i.read()
	with open(r"\\PATH\TO\FILES\RECON-IGTC_Report-ITD.sql") as r:
		recon = r.read()
	return creds, schedule, PgmYr, icon, recon
		
def get_open_and_closed_dates(schedule, dates_for=datetime.date.today()):
    month = str(dates_for.month)
    year = str(dates_for.year)
    start_date = datetime.datetime.strptime(schedule[year][month]['start_date'],'%m/%d/%Y')
    end_date = datetime.datetime.strptime(schedule[year][month]['end_date'],'%m/%d/%Y')
    return start_date, end_date

def convert_date_type(PgmYr):  
	for key, stuff in PgmYr.items():
	#    print(key, stuff)
		for name, dates in stuff.items():
			stuff[name] = datetime.datetime.strptime(dates, '%m/%d/%Y')

def create_folder(end_date):
	newpathmonth = r'\\PATH\TO\FILES\{end_date:%Y}\{end_date:%m%Y}'.format(end_date=end_date)
	if not os.path.exists(newpathmonth):
		os.makedirs(newpathmonth)
###############################################################################
################## CREATE DB CONNECTIONS AND RUN QUERIES ######################
############################################################################### 
def Query_and_csv(recon,icon,end_date,PgmYr):   
	print('Creating connection to data lake server with pyodbc driver...')
	# SQL SERVER/RECON
	Reconcnxn = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=[SERVER_ADDRESS]')
	print('Running Recon query...')
	ReconDF = pd.read_sql(recon, Reconcnxn)
	print('Recon query complete!')
	#ReconDF.to_csv(r"\\PATH\TO\FILES\IGTCrecon.csv")
	# ORACLE/ICON
	print('Creating connection to oracle with cx_oracle driver...')
	ICONcnxn = cx_Oracle.connect('cog{end_date:%y%m}/cog{end_date:%y%m}@mklora601:21600/iconrpt.markelcorp.markelna.com'.format(end_date=end_date))
	print('Running ICON query...')
	ICONDF = pd.read_sql(icon, ICONcnxn)
	print('ICON query complete!\nCombining Recon and ICON DF together...')
	IGTC = pd.concat([ReconDF, ICONDF], ignore_index = True)
	print('ICON and Recon dataframes combined!\nParsing the Loss Date column to datetime format...')
	IGTC['Loss Date'] = IGTC['Loss Date'].apply(lambda x: datetime.datetime.strptime(x, '%Y-%m-%d'))
	print('Parsing complete!\nGetting Program Year based on Loss date...')     
	for rownum, i in enumerate(IGTC['Loss Date']):
		for key, values in PgmYr.items():
			if values['startdate'] <= i < values['enddate']:
				IGTC.iat[rownum,0] = key      

	IGTC['Loss Date'] = IGTC['Loss Date'].apply(lambda x: datetime.datetime.strftime(x, '%Y-%m-%d'))
	print('Saving dataframe to .csv...')
	IGTC.to_csv(r"\\PATH\TO\FILES\IGTC.csv", header = False, index = False)
	print('csv saved!')

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
#         subprocess.call([r"PATH\TO\FILES\AutoHotkey.exe", r"\\PATH\TO\FILES\Enter.ahk"])
#         process = subprocess.Popen([r"PATH\TO\FILES\AutoHotkey.exe",r"\\PATH\TO\FILES\Enter.ahk"])
#         process.wait()
    #cleanup
    print('quitting')
    xl.Application.DisplayAlerts = False
    xl.Application.Quit()  
 
#Create Module
def mail(to, subject, text, attach, email_user, email_pwd):
    print("Assigning Sender, Recipient(s), and Subject of email...")
    msg = MIMEMultipart()
    msg['From'] = email_user
    msg['To'] = ", ".join(to)
    bcc=['USER@EMAIL.com']
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
    mailServer.sendmail(email_user, to+bcc, msg.as_string())
    # Should be mailServer.quit(), but that crashes...
    mailServer.close()
    print('Email Sent!')

def date_format(datestring):
    x = datestring
    x=datetime.datetime.strptime(x,'%m/%Y')
    return x
	
if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv)
    parser.add_argument('-e', type = str, help = 'your outlook email address')
    parser.add_argument('-p', type = str, help = 'your outlook email password (same as your VDI password)')
    parser.add_argument('-d', type = str, help = 'start date (month/year)')
    #	parser.add_argument('--creds', type = str, help = 'the path to your credentials file') # -- is optional
    args = parser.args()
    if (args.e and args.p and args.p):
        main(args.e, args.p, args.d)
    #	elif (args.creds):
    #		with open(args.creds) as c:
    #			creds = json.loads(c.read())
    #		email = creds['c1']
    #		pw = creds['c2']
    #		main(email, pw)
    else:
        raise Exception('Input either your email address and password OR the path to your config file')

	
	
	
