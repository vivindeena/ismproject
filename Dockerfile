FROM ubuntu:latest

RUN apt-get update 
# RUN apt-get install -y postfix
RUN apt-get install -y vim

EXPOSE 587


# apt-get install -y postfix
# echo "[smtp.gmail.com]:587 ismproject002@gmail.com:vrrvttrumxivanhl" >> /etc/postfix/sasl/sasl_passwd
# postmap /etc/postfix/sasl/sasl_passwd
# chown root:root /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db
# chmod 0600 /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db

# sed s/"relayhost = "/"relayhost =  [smtp.gmail.com]:587" /etc/postfix/main.cf > main.cf

echo "
# Enable SASL authentication
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt" >> /etc/postfix/main.cf

# postfix start

# echo "To: vivin.deena@gmail.com
Subject: Hello, this is an Automated Test
Hello this mail is an automated test to check whether postfix can send emails from a docker container" > email.txt
