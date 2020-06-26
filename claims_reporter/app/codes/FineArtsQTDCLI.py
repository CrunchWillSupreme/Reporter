""" 
			Fine Arts QTD CLI
			10/12/18
			Created by Will Han
"""
import json, pyodbc, pandas as pd, datetime, win32com.client, os, smtplib, argparse, sys, time
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from smtplib import SMTPSenderRefused

def main(email_user, email_pwd, datestring, sendmail:bool = False):
    schedule = get_json()
    d_string = date_format(datestring)
    start_date, end_date = get_open_and_closed_dates(schedule, dates_for = d_string)
    create_folder(end_date)
    acctpd = '{end_date:%Y%m}'.format(end_date=end_date)

    FAQTDquery, FAMTDquery, FALossRunQuery = read_queries(acctpd)
    run_queries_csv(FAQTDquery, FAMTDquery, FALossRunQuery)
    
    path = r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\TEMPLATES\FineArts_QTD_TEMPLATE.xlsm'
    macro = 'FineArts.FAFinal'
    saveas = r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Monthly Reporting\{end_date:%Y}\{end_date:%m%Y}\Fine Arts Reports QTD- {end_date:%m%Y}.xlsx'.format(end_date=end_date)
    call_macro(path, macro, save_path = saveas)
    if sendmail:
        flag = False
        while not flag:
            try:
                recipients = ["kevin.phillips@markelintl.com", "robert.ashby@markelintl.com", "rraeder@markelcorp.com", "kchristodoulatos@markelcorp.com", "James.Harrison@Markelintl.com", "kelly.reeder@markel.com", "ben.larkin@markel.com"]
                subject = 'Fine Arts Reports: Monthly Loss Run & QTD Claim Activity'
                text = "All,\n\nPlease see the attached Fine Arts Quarterly reports.  Shown is the Loss Run as well as the QTD Claim Activity report.  The data is current as of {end_date:%B}'s month-end financial close date of {end_date:%B %d %Y}.\n\nPlease note: All reports are based on pre-determined requirements where underwriters are listed as James Gregory, policies effective on and/or after 8/28/2016, or Payce Louis, policies effective on and/or after 5/1/2017.\n\nThe quarterly Loss Run displays all claims as of MEFC. The QTD Claim Activity report displays all new claims within the period and claims that have total incurred movement during the period.\n\nIf there are any questions, comments, or concerns, please advise.\n\nRegards,\n\nWill Han".format(end_date=end_date)
                cc = ["rkincaid@markelcorp.com"]
                report = [r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Monthly Reporting\{end_date:%Y}\{end_date:%m%Y}\Fine Arts Reports QTD- {end_date:%m%Y}.xlsx'.format(end_date=end_date)]
                send_email(recipients, subject, text, report, email_user, email_pwd, cc)
                flag = True
            except SMTPSenderRefused:
                time.sleep(5)
	

def get_json():
    with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\Files\schedule.json') as s:
        schedule = json.loads(s.read())
    return schedule
	
def get_open_and_closed_dates(schedule, dates_for=datetime.date.today()):
    month = str(dates_for.month)
    year = str(dates_for.year)
    start_date = datetime.datetime.strptime(schedule[year][month]['start_date'],'%m/%d/%Y')
    end_date = datetime.datetime.strptime(schedule[year][month]['end_date'],'%m/%d/%Y')
    return start_date, end_date

def create_folder(end_date):
	newpathmonth = r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Monthly Reporting\{end_date:%Y}\{end_date:%m%Y}'.format(end_date=end_date)
	if not os.path.exists(newpathmonth):
		os.makedirs(newpathmonth)
	
def read_queries(acctpd):
    with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\SQL\Edited\FineArtsQTDFn.sql') as f:
        FAQTDquery = f.read().format(acctpd=acctpd)
    with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\SQL\Edited\FineArtsMTDFn.sql') as f:
        FAMTDquery = f.read().format(acctpd=acctpd)
    with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\SQL\Edited\FineArtsLossRunFn.sql') as s:
        FALossRunQuery = s.read().format(acctpd=acctpd)
    return FAQTDquery, FAMTDquery, FALossRunQuery

def run_queries_csv(FAQTDquery, FAMTDquery, FALossRunQuery):
    connection = pyodbc.connect('DRIVER={SQL Server};PORT=1433;SERVER=VA1-PCORSQL191,21612')
    print('Running the FAQTD query...')
    FAQTD = pd.read_sql_query(FAQTDquery, connection)
    print('FAQTD query complete!\nRunning the FAMTD query...')
    FAMTD = pd.read_sql_query(FAMTDquery, connection)
    print('FAMTD query complete!\nRunning the FALossRun query...')
    FALossRun = pd.read_sql_query(FALossRunQuery, connection)
    print('FALossRun query complete!')
    print("Saving FAQTD as a .csv in the 'ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv' folder...")
    FAQTD.to_csv(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv\FAQTD.csv', header = False, index = False)
    print("Saving FAMTD as a .csv in the 'ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv' folder...")
    FAMTD.to_csv(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv\FAMTD.csv', header = False, index = False)
    print("FAMTD.csv saved!\nSaving FALossRun as a .csv in the 'ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv' folder...")
    FALossRun.to_csv(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\files\csv\FALossRun.csv', header = False, index = False)
    print('FALossRun.csv saved!')

def date_format(datestring):
    x = datestring
    x = datetime.datetime.strptime(x, '%m/%Y')
    return x

def call_macro(wb_path, macro_name, *args, save_path = None):
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
    xl = win32com.client.Dispatch('Excel.Application')
    print(f'loaded excel as "{xl}".')
    wb = xl.Workbooks.Open(Filename = wb_path)
    print(f'loaded workbook as "{wb.Name}"')
    print(f'calling {wb.Name}!{macro_name}...',*args)
    if any(args):
        xl.Application.Run(f'{wb.Name}!{macro_name}', *args)
    else:
        xl.Application.Run(f'{wb.Name}!{macro_name}')
    print('Saving...')
    if save_path is not None:
        xl.Application.Run(f'{wb.Name}!save_xlsx', save_path)
    print('Quitting...')
    xl.Application.DisplayAlerts = False
    xl.Application.Quit()

def send_email(to, subject, text, report, email_user, email_pwd, cc=None):
    print('Assigning sender, recipient(s), and subject of mail...')
    msg = MIMEMultipart()
    msg['From'] = email_user
    msg['To'] = " ,".join(to)
    msg['CC'] = " ,".join(cc)
    bcc = ['whan@markelcorp.com']
    msg['Subject'] = subject
    print('Adding body of message')
    msg.attach(MIMEText(text))
    print('Formatting Attachments...')
    for file in report:
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

if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv)
    parser.add_argument('-e', type = str, help = 'your outlook email address')
    parser.add_argument('-p', type = str, help = 'the password to your outlook email (same as your VDI)')
    parser.add_argument('-d', type = str, help = 'the date')
    parser.add_argument('--creds', type = str, help = 'the path to your credentials file')
    args = parser.args()
    if (args.e and args.p):
        main(args.e, args.p)
    elif (args.creds):
        with open(args.creds) as c:
            creds = json.loads(c.read())
            email = creds['c1']
            pw = creds['c2']
            main(email, pw)
    else:
        raise Exception('Input either your email address and password OR the path to your config file')
		
