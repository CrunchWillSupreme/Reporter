from flask import render_template, flash, redirect, url_for, request, Response, send_file

from app import app, db
from app.forms import LoginForm, RegistrationForm, Changepw, CAT, ADMICON, Ack, Matter, QuerySearch, IGTC, ProfitPrimis, MedMal, FineArts, FineArtsQTD
from flask_login import current_user, login_user, logout_user,login_required
from app.models import User
from app.codes.CAT_CLI import main as catmain
#from app.codes.CATDOL import main as catmain
from app.codes.ADMICONMonthlies import single_report, ADM_reports, ICON_reports, main as ADMICONMain
from app.codes.AckLetterCLI import main as Ackmain, create_folder as Ack_create_folder
from app.codes.Muploadcli import main as Mattermain
from app.codes.Querysearch import main as Querysearch
from app.codes.ProfitPrimisOpenCloseCLI import main as profprim
from app.codes.IGTCCLI import main as IGTCmain
from app.codes.MedMal_SpecMed import main as medmal
from app.codes.FineArtsCLI import main as fine_arts
from app.codes.FineArtsQTDCLI import main as fine_arts_QTD
from app.codes.quick_logger import QLogger
import os, datetime, time
import xlsxwriter
#, Role
#from flask_user import roles_required

#import app.ADMMonthliesClassy as admpy
from werkzeug.urls import url_parse


#admin = Role.query.filter_by(name='admin').first()
#cat = Role.query.filter_by(name='cat').first()

# GLOBAL VARIABLES
# GLOBAL lOG VARIABLES
logger = QLogger.getInstance()

@app.route('/export')
def export(): 
    from io import BytesIO
    output = BytesIO()
    workbook = xlsxwriter.Workbook(output, {'in_memory': True})
    worksheet = workbook.add_worksheet()
    expenses = (
        ['Rent', 1000.0],
        ['Gas',   100.0],
        ['Food',  300.0],
        ['Gym',    50.0],)
    expenses = list(map(list, zip(*expenses)))
    print(expenses)
    row=0
    col=0
    for line in expenses:
        worksheet.write_row(row, col, line)
#        worksheet.write(row,col + 1, cost)
        row += 1
    workbook.close()
    
    output.seek(0) #reset buffer to beginning
    
    return send_file(output, attachment_filename="workbook.xlsx", mimetype='application/xlsx', as_attachment=True)

@app.route('/home')
@login_required
def home():
#    user = {'username':'Boss'}
    return render_template('home.html', title='Home') 
#                           ,admin=admin, cat=cat)

@app.route('/', methods=['GET', 'POST'])
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first()
        if user is None or not user.check_password(form.password.data):
            flash('Invalid username or password')
            return redirect(url_for('login'))
        login_user(user, remember=form.remember_me.data)
        next_page = request.args.get('next')
        if not next_page or url_parse(next_page).netloc != '':
            next_page = url_for('home')
        return redirect(next_page)
    return render_template('loginWTF.html', title='Log In', form=form)
#                           , admin=admin, cat=cat)

@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
@login_required
#@roles_required('admin')
def register():
#    admin = Role.query.filter_by(name='admin').first()
    if current_user.role != 'admin':
        return redirect(url_for('accessdenied'))
#    if current_user.is_authenticated:
#        return redirect(url_for('home'))
    form = RegistrationForm()
    if form.validate_on_submit():
#        role = Role.query.filter_by(name=form.role.data).first()
        user = User(username=form.username.data, email=form.email.data, role = form.role.data)
#        user.role.append(Role(name=form.role.data)) #not sure what to do here
        user.set_password(form.password.data)
        db.session.add(user)
        db.session.commit()
        flash('Congratulations, you have registered a user!')
        return redirect(url_for('registersuccess'))
    return render_template('registerWTF.html', title='Register', form=form)
#, admin=admin, cat=cat)

@app.route('/accessdenied')
def accessdenied():
    return render_template('accessdenied.html', title='You Shall Not Pass')
#, admin=admin, cat=cat)

@app.route('/registersuccess')
@login_required
def registersuccess():
    return render_template('registersuccess.html', title='Register Success')

@app.route('/cat', methods=['GET', 'POST'])
@login_required
def cat():
    if not current_user.check_role('cat'):
        return redirect(url_for('accessdenied'))
    form = CAT()
    email_user = form.emailadd.data
    email_pwd = form.password.data
    send_email = form.send_email.data
    if request.method == 'GET':
        return render_template('catWTF.html', form=form)
    if request.method == 'POST':
        catmain(email_user, email_pwd, send_email)
        return render_template('report_success.html')
    return render_template('catWTF.html', title='CAT Report', form=form)

@app.route('/log_console')
@login_required
def log_console():
    def eventStream():
        global logger
        while True:
            if logger.new_record != None:
                logger.log_records += logger.new_record
                logger.new_record = None
                yield "data: {}\n\n".format(logger.log_records)
            logger.log_records != 'Hello<br>'
            yield "data: {}\n\n".format(logger.log_records)
            time.sleep(1)
    return Response(eventStream(), mimetype="text/event-stream")

@app.route('/EFormatter/')
@login_required
def EFormatter():
    path = "P:\GitHub\claims_reporter\FILES\CAT\TEMPLATES\EFormatterTemplate.xlsm"
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('cat'))

@app.route('/CATArchive/')
@login_required
def CATArchive():
    the_date = datetime.date.today()
    the_year = the_date.year
    path = "//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Ad Hoc Reporting//{the_year}//CAT//Reports//".format(the_year=the_year)
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('cat'))

@app.route('/ack', methods=['GET', 'POST'])
@login_required
def ack():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if not current_user.check_role('ack'):
        return redirect(url_for('accessdenied'))
    form = Ack()
    Ack_create_folder()
    if request.method == 'GET':
        return render_template('ack.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        Ackmain(form.emailadd.data, form.password.data, form.send_email.data)
        return render_template('report_success.html')
    return render_template('ack.html', title='Acknowledgement Letter Add-In', form=form)

@app.route('/ackinput/')
@login_required
def ackinput():
    the_date = datetime.date.today()
    the_year = the_date.year
    the_month = datetime.datetime.strftime(the_date, "%B")
    path = "//Mklfile//claims//corpfs06-filedrop//ClaimsReporting//Acknowledgment Letter Add In//Input//{year}//{month}".format(year=the_year, month=the_month)
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('ack'))

@app.route('/AckArchive/')
@login_required
def AckArchive():
#    the_date = datetime.date.today()
#    the_year = the_date.year
    path = f"//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Acknowledgment Letter Add In//{datetime.date.today().year}//{datetime.datetime.strftime(datetime.date.today(),'%B')}//"
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('ack'))

@app.route('/admicon', methods=['GET', 'POST'])
@login_required
def admicon():
    if current_user.role not in ['admin']:
        return redirect(url_for('accessdenied'))
#    with open(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\Files\CognosADMFiles.json') as c:
#        reports = json.loads(c.read())
    form = ADMICON()
#    report = form.report.data
    
    if request.method == 'GET':
        return render_template('admiconTD.html', form = form)
#    if form.validate_on_submit():        
    if request.method == 'POST':
        
        if form.report.data == 'Run All':
            flash('YOU SELECTED RUN ALL!! The email address is: '+form.emailadd.data+' The Report is: '+form.report.data+' The date is: '+form.date.data)
            ADMICONMain(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        elif form.report.data == 'ICON Reports':
            flash('YOU SELECTED ICON REPORTS ONLY! The email address is: '+form.emailadd.data+' The Report is: '+form.report.data+' The date is: '+form.date.data)
            ICON_reports(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        elif form.report.data == 'ADM Reports':
            flash('YOU SELECTED ADM REPORTS ONLY! The email address is: '+form.emailadd.data+' The Report is: '+form.report.data+' The date is: '+form.date.data)
            ADM_reports(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        else:
            flash('The email address is: '+form.emailadd.data+' The Report is: '+form.report.data+' The date is: '+form.date.data)
            single_report(form.report.data, form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return redirect(url_for('admiconsuccess'))
    return render_template('admiconTD.html', title='ADM and ICON Reports', form=form)

@app.route('/ADMICONArchive/')
@login_required
def ADMICONArchive():

    the_date = datetime.datetime.today()
#    monthyear = the_date.strftime("%m%Y")
    the_year = the_date.year
#    path = "//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Monthly Reporting//{the_year}//{monthyear}//".format(the_year=the_year, monthyear=monthyear)
    path2 = f"//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Monthly Reporting//{the_year}//"
    if not os.path.exists(path2):
        os.makedirs(path2)
        path = os.path.realpath(path2)
        os.startfile(path)
    else:
        path = os.path.realpath(path2)
        os.startfile(path)
    return redirect(url_for('admicon'))

@app.route('/matter', methods=['GET','POST'])
@login_required
def matter():
    if not current_user.check_role('matter'):
        return redirect(url_for('accessdenied'))
    form=Matter()
    if request.method == 'GET':
        return render_template('matter.html', form = form)
    if request.method == 'POST':
        Mattermain(form.emailadd.data, form.password.data, send_mail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('matter.html', title='Matter Upload', form=form)

@app.route('/MatterArchive/')
@login_required
def MatterArchive():
    the_date = datetime.date.today()
    the_year = the_date.year
    path = f"//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Projects//Matter_Upload//Files//reports//{the_year}//"
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('matter'))

@app.route('/igtc', methods=['GET', 'POST'])
@login_required
def igtc():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if current_user.role not in ['admin']:
        return redirect(url_for('accessdenied'))
    form = IGTC()
#    Ack_create_folder()
    if request.method == 'GET':
        return render_template('igtc.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        IGTCmain(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('igtc.html', title='IGTC Report', form=form)

@app.route('/igtcArchive/')
@login_required
def igtcArchive():
#    the_date = datetime.date.today()
#    the_year = the_date.year
    path = f"//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Monthly Reporting//{datetime.date.today().year}//{datetime.datetime.strftime(datetime.date.today(),'%m%Y')}//"
    path = os.path.realpath(path)
    os.startfile(path)
    return redirect(url_for('igtc'))

@app.route('/profitprimis', methods=['GET', 'POST'])
@login_required
def profitprimis():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if not current_user.check_role('profitprimis'):
        return redirect(url_for('accessdenied'))
    form = ProfitPrimis()
#    Ack_create_folder()
    if request.method == 'GET':
        return render_template('profitprimis.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        profprim(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('profitprimis.html', title='Profit Primis Report', form=form)

@app.route('/medmal', methods=['GET', 'POST'])
@login_required
def med_mal():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if not current_user.check_role('medmal'):
        return redirect(url_for('accessdenied'))
    form = MedMal()
#    Ack_create_folder()
    if request.method == 'GET':
        return render_template('medmal.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        medmal(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('medmal.html', title='Med Mal Spec Med Report', form=form)

@app.route('/MedMalArchive/')
@login_required
def medmal_archive():
    the_date = datetime.datetime.today()
#    monthyear = the_date.strftime("%m%Y")
    the_year = the_date.year
#    path = "//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Monthly Reporting//{the_year}//{monthyear}//".format(the_year=the_year, monthyear=monthyear)
    path2 = f"//Mklfile\claims//corpfs06-filedrop//ClaimsReporting//Ad Hoc Reporting//{the_year}//Jagady Blue - Spec Med & Med Mal"
    path = os.path.realpath(path2)
    os.startfile(path)
    return redirect(url_for('med_mal'))

@app.route('/finearts', methods=['GET', 'POST'])
@login_required
def finearts():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if current_user.role not in ['admin']:
        return redirect(url_for('accessdenied'))
    form = FineArts()
#    Ack_create_folder()
    if request.method == 'GET':
        return render_template('finearts.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        fine_arts(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('finearts.html', title='Fine Arts MTD/Loss Run Report', form=form)

@app.route('/fineartsQTD', methods=['GET', 'POST'])
@login_required
def fineartsQTD():
#    if current_user.role not in ['ack','admin']:
#        return redirect(url_for('accessdenied'))
#    return render_template('ack.html', title='Acknowledgement Letter Report')
    if current_user.role not in ['admin']:
        return redirect(url_for('accessdenied'))
    form = FineArtsQTD()
#    Ack_create_folder()
    if request.method == 'GET':
        return render_template('fineartsQTD.html', form=form)
    if request.method == 'POST':
        flash('The email address is: '+form.emailadd.data+" The checkbox shows: "+str(form.send_email.data))
        fine_arts_QTD(form.emailadd.data, form.password.data, form.date.data, sendmail=form.send_email.data)
        return render_template('report_success.html')
    return render_template('fineartsQTD.html', title='Fine Arts QTD/Loss Run Report', form=form)

@app.route('/changepw_success', methods=['GET'])
def changepw_success():
    return render_template('changepw_success.html', title='Password Change Successful')

@app.route('/changepw', methods=['GET', 'POST'])
@login_required
def changepw():
    form = Changepw(current_user.email) # Should be emailadd, and should input
    if form.validate_on_submit():
        current_user.email = form.emailadd.data
        current_user.set_password(form.password.data)
        db.session.commit()
        flash('Your changes have been saved.')
        return redirect(url_for('changepw_success'))
    elif request.method == 'GET':
        form.emailadd.data = current_user.email
    return render_template('changepw.html', title='Change Password',
                           form=form)

@app.route('/querysearch', methods=['GET', 'POST'])
@login_required
def querysearch():
    form=QuerySearch()
    if request.method == 'GET':
        return render_template('querysearch.html', form=form)
    if request.method == 'POST':
#    if form.validate_on_submit():
        results=Querysearch(form.keyword.data, form.year.data)
        table =results.to_html(classes=["table","table-warning","table-responsive","table-bordered", "table-striped", "table-hover", "table thead-light"])
        table = table.replace('\\n','\n')
        flash(f"The year selected is: {form.year.data}")
        return render_template('querysearch.html', form=form,data=table)
    return render_template('querysearch.html', title='Query Search', form=form)

@app.route('/admiconsuccess', methods=['GET'])
def admiconsuccess():
#    form = ADMICON()
#    d = form.date.data
    return render_template('admiconsuccess.html', title='ADM ICON Success')






    