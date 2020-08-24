perl {
	filename = ${modconfdir}/${.:instance}/rlm_perl.pl
	config {
		db {
			host = $ENV{DB_HOST}
			name = $ENV{DB_NAME}
			user = $ENV{DB_USER}
			password = $ENV{DB_PASS}
		}
		smtp {
			server = $ENV{SMTP_SERVER}
			port = $ENV{SMTP_PORT}
			user = $ENV{SMTP_USER}
			pass = $ENV{SMTP_PASS}
			admin_email = $ENV{SMTP_ADMIN_EMAIL}
			sender_email = $ENV{SMTP_SENDER_EMAIL}
			subject = $ENV{SMTP_SUBJECT}
		}
	}
}
