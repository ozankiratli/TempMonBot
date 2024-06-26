import smtplib

from string import Template

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

MY_ADDRESS = 'myemailaddress@example.com'
PASSWORD = 'jsdflajdflasjdflaasfa'

def get_contacts(filename):
	"""
	Return two lists names, emails containing names and email addresses
	read from a file specified by filename.
	"""

	names = []
	emails = []
	with open(filename, mode='r') as contacts_file:
		for a_contact in contacts_file:
			names.append(a_contact.split()[0])
			emails.append(a_contact.split()[1])
	return names, emails

def read_template(filename):
	"""
	Returns a Template object comprising the contents of the 
	file specified by filename.
	"""

	with open(filename, 'r') as template_file:
		template_file_content = template_file.read()
	return Template(template_file_content)

def main():
	names, emails = get_contacts('/home/thermobot/Monitor/CONTACTS') # read contacts
	message_template = read_template('/home/thermobot/Monitor/MESSAGE')
	# set up the SMTP server
	s = smtplib.SMTP('smtp.gmail.com', 587)
	s.starttls()
	s.login(MY_ADDRESS, PASSWORD)
	SUBJECT=open("/home/thermobot/Monitor/SUBJECT").readline().rstrip()
	# For each contact, send the email:
	for name, email in zip(names, emails):
		msg = MIMEMultipart()       # create a message

		# add in the actual person name to the message template
		message = message_template.substitute(PERSON_NAME=name.title())

		# setup the parameters of the message
		msg['From']=MY_ADDRESS
		msg['To']=email
		msg['Subject']=SUBJECT

		# add in the message body
		msg.attach(MIMEText(message, 'plain'))
		print(msg)
		# send the message via the server set up earlier.
		s.sendmail(MY_ADDRESS, email, msg.as_string())
		del msg

	# Terminate the SMTP session and close the connection
	s.quit()

if __name__ == '__main__':
	main()
