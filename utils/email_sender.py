# import smtplib
# from email.mime.text import MIMEText
# #superadminforgot password
# def send_email(to_email, subject, message):
#     from config import Config
    
#     msg = MIMEText(message)
#     msg["Subject"] = subject
#     msg["From"] = Config.EMAIL_USER
#     msg["To"] = to_email

#     server = smtplib.SMTP("smtp.gmail.com", 587)
#     server.starttls()
#     server.login(Config.EMAIL_USER, Config.EMAIL_PASS)
#     server.sendmail(Config.EMAIL_USER, to_email, msg.as_string())
#     server.quit()
# #admin email
# def send_admin_email(email, name, username, password):
#     login_url = "http://127.0.0.1:5000/admin-login"  # change to your domain
#     subject = "Your Admin Account Created"
#     body = f"""
#     Hello {name},

#     You have been added as an admin to our hospital system.

#     Your login credentials:
#     Username: {username}
#     Password: {password}

#     Login here: {login_url}
#     """

#     msg = MIMEText(body)
#     msg['Subject'] = subject
#     msg['From'] = "your_email@example.com"
#     msg['To'] = email

#     # Using SMTP (example: Gmail)
#     with smtplib.SMTP("smtp.gmail.com", 587) as server:
#         server.starttls()
#         server.login("your_email@example.com", "your_email_password")
#         server.send_message(msg)
import smtplib
from email.mime.text import MIMEText
from config import Config

# Superadmin forgot password / general email
def send_email(to_email, subject, message):
    msg = MIMEText(message)
    msg["Subject"] = subject
    msg["From"] = Config.EMAIL_USER
    msg["To"] = to_email

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(Config.EMAIL_USER, Config.EMAIL_PASS)
        server.sendmail(Config.EMAIL_USER, to_email, msg.as_string())

# Admin account created email
def send_admin_email(email, name, username, password):
    login_url = "http://127.0.0.1:5000/admin-login"  # change to your domain
    subject = "Your Admin Account Created"
    body = f"""Hello {name},

You have been added as an admin to our hospital system.

Your login credentials:
Username: {username}
Password: {password}

Login here: {login_url}
"""

    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = Config.EMAIL_USER
    msg['To'] = email

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(Config.EMAIL_USER, Config.EMAIL_PASS)
        server.send_message(msg)
