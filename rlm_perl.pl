#!/usr/bin/perl
#
#  Script purpose
#  Cache keeper ( DB + expiration )
#  Cache logic if not present in DB we return noop and pass authentication to imap module after successful authentication we remember user and pass to DB
#  Cache timeout 
#  Send Email on Failed authentication
#
#
#
#
use strict;
use warnings;
use DBI;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTPS();
use Email::Simple ();
use Email::Simple::Creator ();
use Data::Dumper;



# Bring the global hashes into the package scope
our (%RAD_REQUEST, %RAD_REPLY, %RAD_CONFIG, %RAD_STATE);

# This is hash wich hold original request from radius
#my %RAD_REQUEST;
# In this hash you add values that will be returned to NAS.
#my %RAD_REPLY;
#This is for config items (was %RAD_CHECK in earlier versions)
#my %RAD_CONFIG;
# This is the session-sate
#my %RAD_STATE;
# This is configuration items from "config" perl module configuration section
#my %RAD_PERLCONF;

use constant {
	RLM_MODULE_REJECT   => 0, # immediately reject the request
	RLM_MODULE_OK       => 2, # the module is OK, continue
	RLM_MODULE_HANDLED  => 3, # the module handled the request, so stop
	RLM_MODULE_INVALID  => 4, # the module considers the request invalid
	RLM_MODULE_DISALLOW => 5, # reject the request (user is locked out)
	RLM_MODULE_NOTFOUND => 6, # user not found
	RLM_MODULE_NOOP     => 7, # module succeeded without doing anything
	RLM_MODULE_UPDATED  => 8, # OK (pairs modified)
	RLM_MODULE_NUMCODES => 9  # How many return codes there are
};

use constant {
	L_AUTH         => 2,  # Authentication message
	L_INFO         => 3,  # Informational message
	L_ERR          => 4,  # Error message
	L_WARN         => 5,  # Warning
	L_PROXY        => 6,  # Proxy messages
	L_ACCT         => 7,  # Accounting messages
	L_DBG          => 16, # Only displayed when debugging is enabled
	L_DBG_WARN     => 17, # Warning only displayed when debugging is enabled
	L_DBG_ERR      => 18, # Error only displayed when debugging is enabled
	L_DBG_WARN_REQ => 19, # Less severe warning only displayed when debugging is enabled
	L_DBG_ERR_REQ  => 20, # Less severe error only displayed when debugging is enabled
};


sub failed_auth {
# email credentials
my $smtpserver = $RAD_PERLCONF{'smtp'}->{'server'};
my $smtpport = $RAD_PERLCONF{'smtp'}->{'port'};
my $smtpuser   = $RAD_PERLCONF{'smtp'}->{'user'};
my $smtppassword = $RAD_PERLCONF{'smtp'}->{'pass'};

my $transport = Email::Sender::Transport::SMTPS->new({
host => $smtpserver,
port => $smtpport,
ssl  => 'starttls',
sasl_username => $smtpuser,
sasl_password => $smtppassword,
});

my $email = Email::Simple->create(
header => [
To      => $RAD_PERLCONF{'smtp'}->{'admin_email'},
From    => $RAD_PERLCONF{'smtp'}->{'sender_email'},
Subject => $RAD_PERLCONF{'smtp'}->{'subject'},
],
body => "Failed authentication from $RAD_REQUEST{'User-Name'} \n",
);

sendmail($email, { transport => $transport });
}



# Function to handle authorize
sub authorize {
	# For debugging purposes only
#	log_request_attributes();

	# Here's where your authorization code comes
	# You can call another function from here:
	test_call();

	return RLM_MODULE_OK;
}


sub authenticate {
	# For debugging purposes only
#	log_request_attributes();

	if ($RAD_REQUEST{'User-Name'} =~ /^baduser/i) {
		# Reject user and tell him why
		$RAD_REPLY{'Reply-Message'} = "Denied access by rlm_perl function";
		return RLM_MODULE_REJECT;
	} else {
		# Accept user and set some attribute
		if (&radiusd::xlat("%{client:group}") eq 'UltraAllInclusive') {
			# User called from NAS with unlim plan set, set higher limits
			$RAD_REPLY{'h323-credit-amount'} = "1000000";
		} else {
			$RAD_REPLY{'h323-credit-amount'} = "100";
		}
		return RLM_MODULE_OK;
	}
}


# Function to handle preacct
sub preacct {
	# For debugging purposes only
#	log_request_attributes();

	return RLM_MODULE_OK;
}


# Function to handle accounting
sub accounting {
	# For debugging purposes only
#	log_request_attributes();

	# You can call another subroutine from here
	test_call();

	return RLM_MODULE_OK;
}


# Function to handle pre_proxy
sub pre_proxy {
	# For debugging purposes only
#	log_request_attributes();

	return RLM_MODULE_OK;
}

# Function to handle post_proxy
sub post_proxy {
	# For debugging purposes only
#	log_request_attributes();

	return RLM_MODULE_OK;
}

# Function to handle post_auth
sub post_auth {
	# For debugging purposes only
#	log_request_attributes();

	return RLM_MODULE_OK;
}


# Function to handle xlat
sub xlat {
	# For debugging purposes only
#	log_request_attributes();

	# Loads some external perl and evaluate it
	my ($filename,$a,$b,$c,$d) = @_;
	radiusd::radlog(L_DBG, "From xlat $filename");
	radiusd::radlog(L_DBG,"From xlat $a $b $c $d");
	local *FH;
	open FH, $filename or die "open '$filename' $!";
	local($/) = undef;
	my $sub = <FH>;
	close FH;
	my $eval = qq{ sub handler{ $sub;} };
	eval $eval;
	eval {main->handler;};
}

# Function to handle detach
sub detach {
	# For debugging purposes only
#	log_request_attributes();
}

sub database {

my $dbName 		= $RAD_PERLCONF{'db'}->{'name'};
my $dbUsername	= $RAD_PERLCONF{'db'}->{'user'};
my $dbPassword 	= $RAD_PERLCONF{'db'}->{'password'};
my $radiusUserPassword = $RAD_REQUEST{'User-Password'};

try {
	my $dbInstance = DBI->connect(
	"dbi:mysql:dbname=$dbName",
	$dbUsername,
	$dbPassword,
	{ RaiseError => 1 },
	);
}
	my $query = $dbInstance->prepare("SELECT * FROM cache_users WHERE username=? LIMIT 1");
	$query->execute($username);

	my $result = $query->fetchrow_arrayref();
	$password = @$result[2];

	$query->finish();
	$dbInstance->disconnect();

    if ($password == $radiusUserPassword) { 
    return RLM_MODULE_OK;
    }
    else {
    return RLM_MODULE_NOOP;
    }
}

sub check_in_cache { 

my $dbName 		= $RAD_PERLCONF{'db'}->{'name'};
my $dbUsername	= $RAD_PERLCONF{'db'}->{'user'};
my $dbPassword 	= $RAD_PERLCONF{'db'}->{'password'};
my $radiusUserPassword = $RAD_REQUEST{'User-Password'};

try {
	my $dbInstance = DBI->connect(
	"dbi:mysql:dbname=$dbName",
	$dbUsername,
	$dbPassword,
	{ RaiseError => 1 },
	);
}
	my $query = $dbInstance->prepare("SELECT * FROM cache_users WHERE username=? LIMIT 1");
	$query->execute($username);

	my $result = $query->fetchrow_arrayref();
	$password = @$result[2];

	$query->finish();
	$dbInstance->disconnect();

    if ($password == $radiusUserPassword) { 
    return RLM_MODULE_OK;
    }
    else {
    return RLM_MODULE_NOOP;
    }

}

sub cache_expiration { 

my $dbName 		= $RAD_PERLCONF{'db'}->{'name'};
my $dbUsername	= $RAD_PERLCONF{'db'}->{'user'};
my $dbPassword 	= $RAD_PERLCONF{'db'}->{'password'};
my $radiusUserPassword = $RAD_REQUEST{'User-Password'};

try {
	my $dbInstance = DBI->connect(
	"dbi:mysql:dbname=$dbName",
	$dbUsername,
	$dbPassword,
	{ RaiseError => 1 },
	);
}
	my $query = $dbInstance->prepare("SELECT * FROM cache_users WHERE cache_time  LIMIT 1");
	$query->execute($username);

	my $result = $query->fetchrow_arrayref();
	$password = @$result[2];

	$query->finish();
	$dbInstance->disconnect();

    if ($password == $radiusUserPassword) { 
    return RLM_MODULE_OK;
    }
    else {
    return RLM_MODULE_NOOP;
    }

}

sub insert_to_cache { 
database();
	log_request_attributes();
$dbh->do("INSERT INTO cache_users VALUES (?, ?)", $RAD_REQUEST{'User-Name'}, $RAD_REQUEST{'Cleartext-Password'});

	return RLM_MODULE_OK;

}




sub test_call {
	# Some code goes here
}

sub log_request_attributes {
	# This shouldn't be done in production environments!
	# This is only meant for debugging!
	for (keys %RAD_REQUEST) {
		radiusd::radlog(L_DBG, "RAD_REQUEST: $_ = $RAD_REQUEST{$_}");
	}
}
