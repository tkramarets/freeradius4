# freeradius4

# How to run : 

1) edit docker-compose.yaml or docker-compose_with_mysql.yaml 

following arguments will be taken from docker-compose file:
   DB_HOST <- hostname or ip address of MySQL
   DB_NAME <- database name 
   DB_USER <- database username
   DB_PASS <- database password
   AUTH_TABLE <- name of table
   SMTP_SERVER <- SMTP server used for send mail to Admin about failed logins
   SMTP_PORT  <- SMTP port 
   SMTP_USER  <- SMTP username
   SMTP_PASS  <- SMTP password
   SMTP_ADMIN_EMAIL <- Email of Admin
   SMTP_SENDER_EMAIL <- sender email usually it will be same as SMTP username
   SMTP_SUBJECT  <- Subject of letter
   CACHE_TIME  <- cache time in MINUTES (integer) 
   IMAP_TIMEOUT <- IMAP timeout in seconds 
   IMAP_URI  <- IMAP_URI can be smtp/smtps, imap/imaps pop etc.

2) if you run docker-compose.yaml ( used with external DB )

docker-compose up

2) if you run docker-compose_with_mysql.yaml ( used with DB inside docker )

docker -f docker-compose_with_mysql.yaml up

2.1) load the dump to database container :

docker exec freeradius4_mysql_1 mysql -u {username} -p {password} {database name } < ./radius.sql


to test working configuration : 
radtest  user@example.com "Password" 10.0.0.2:1812 1812 testing123


to stop the docker-compose:

docker-compose down

or 

docker-compose -f docker-compose_with_mysql.yaml down




