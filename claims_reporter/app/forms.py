from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, SelectField, DateField, SelectMultipleField
from wtforms.validators import ValidationError, DataRequired, Email, EqualTo
from app.models import User
import json



class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Log In')
    
class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
    role = SelectField('Role', choices=[('admin','Admin'), ('cat','CAT'), ('ack','Acknowledgement Letter'),('matter','Matter Upload'),('profit primis','Profit Primis'),('medmal', 'Med Mal')])
    submit = SubmitField('Register')
    
    def validate_username(self, username):
        user = User.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError('Please use a different username.')
    
    def validate_email(self, email):
        user = User.query.filter_by(email=email.data).first()
        if user is not None:
            raise ValidationError('Please use a different email address.')
            
class Changepw(FlaskForm):
    emailadd = StringField('Email Address', validators=[DataRequired()])
    password = PasswordField('New Password', validators=[DataRequired()])
    submit = SubmitField('Submit')
    
    def __init__(self, original_username, *args, **kwargs):
        super(Changepw, self).__init__(*args, **kwargs)
        self.original_username = original_username

class CAT(FlaskForm):
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')

class ADMICON(FlaskForm):
    
    with open(r'\\Mklfile\claims\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\Files\CLI with VBA\CognosADMFiles.json') as f:
        dic = json.loads(f.read())
    with open(r'\\Mklfile\claims\corpfs06-filedrop\ClaimsReporting\Projects\Monthly_Cognos_Reports\Files\CLI with VBA\CognosICONFiles.json') as f:
        dic2 = json.loads(f.read())

    choice_list = [(report, report) for report in dic.keys()]    
    for report in dic2.keys():
        choice_list.append((report,report))
#    other_stuff = [('Run All','Run All'),('ICON Reports','ICON Reports'),('ADM Reports,ADM Reports')]
#    for i in other_stuff:
#        choice_list.append(i)
        
    date = StringField('date', validators=[DataRequired()])
    report = SelectField('Report',choices = choice_list)
#    report = SelectField('Report',choices=[('BrokerageCasualty$250k750k','BrokerageCasualty$250k750k'),('AllClaimsBrokerageProp','AllClaimsBrokerageProp'),('OceanMarine$25k','OceanMarine$25k'),('InlandMarineBuildersRisk$50k','InlandMarineBuildersRisk$50k'),('InlandMarineBuildersRisk$25k','InlandMarineBuildersRisk$25k'),('BrokeragePropMidsouth$50k','BrokeragePropMidsouth$50k'),('AG_100k','AG_100k'),('AM_Skier','AM_Skier'),('ChildDevSchoolsChildCareNet','ChildDevSchoolsChildCareNet'),('GlobalHealthcarePractice','GlobalHealthcarePractice'),('InHomeChildCare_1k','InHomeChildCare_1k'),('CampYouthRec_50k','CampYouthRec_50k'),('FitnessPestFunPro_50k','FitnessPestFunPro_50k'),('ChildCareA&H_100k','ChildCareA&H_100k'),('SocialServices','SocialServices'),
#                                           ('ICON Reports','ICON Reports'),('ADM Reports','ADM Reports'),('Run All','Run All'),('TestReport','TestReport'),('AnotherTestReport','AnotherTestReport')])
    send_email = BooleanField('Send Email?')
    emailadd = StringField('Your Email', validators=[Email()])
    password = PasswordField('Your Email Password')
    submit = SubmitField('Run Report')
    
class Ack(FlaskForm):
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email = BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
class Matter(FlaskForm):
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
class IGTC(FlaskForm):
    date = StringField('date', validators=[DataRequired()])
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
class ProfitPrimis(FlaskForm):
    date = StringField('date', validators=[DataRequired()])
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')

class MedMal(FlaskForm):
    date = StringField('date', validators=[DataRequired()])
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
class FineArts(FlaskForm):
    date = StringField('date', validators=[DataRequired()])
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
class FineArtsQTD(FlaskForm):
    date = StringField('date', validators=[DataRequired()])
    emailadd = StringField('Your Email Address', validators=[Email()])
    password = PasswordField('Your Password')
    send_email =  BooleanField('Send Email?')
    submit = SubmitField('Run Report')
    
    
class QuerySearch(FlaskForm):
#    stuff = [2019, 2018, 2017]
#    for i in stuff:
#        i = BooleanField(i)
    year = SelectField('Year', choices=[('2019','2019'), ('2020','2020'), ('All','All')])
    keyword = StringField('Enter Keyword', [DataRequired()])
    submit = SubmitField('Search')