#!/usr/bin/perl -w 
#####################################################################################################################
#
#  *Script purpose*
#
#  Cache keeper ( DB + expiration )
#
#  Cache logic if not present in DB we return noop and pass authentication to imap module after successful
#  authentication we remember user and pass to DB via rlm_perl
#
#  Cache timeout
#  Send Email on Failed authentication
#
#  writen by Taras.Kramarets aka tarasnix (c) 2020 freelancehunt project
#  v.0.0.1
#
######################################################################################################################

use DBI;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTPS;
use Email::Simple::Creator;
use Try::Tiny;

use vars qw/%RAD_PERLCONF %RAD_REQUEST %RAD_REPLY %RAD_CHECK %RAD_REQUEST_PROXY %RAD_REQUEST_PROXY_REPLY/;

my %RAD_CONFIG;

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



use constant    L_DBG=>         1;
use constant    L_AUTH=>        2;
use constant    L_INFO=>        3;
use constant    L_ERR=>         4;
use constant    L_PROXY=>       5;
use constant    L_CONS=>        128;


&radiusd::log(L_DBG, '-=======================perl module======================-');


&cache_expiration();

sub failed_auth {
&cache_expiration();
# email credentials
&radiusd::log(L_DBG, '-=======================failed auth global===========================');

       my $smtpserver = $RAD_PERLCONF{'smtp'}->{'server'};
       my $smtpport = $RAD_PERLCONF{'smtp'}->{'port'};
       my $smtpuser   = $RAD_PERLCONF{'smtp'}->{'user'};
       my $smtppassword = $RAD_PERLCONF{'smtp'}->{'pass'};

&radiusd::log(L_DBG, '-=====================FAILED AUTH=======================-');

my $transport = Email::Sender::Transport::SMTPS->new(
        host => "$smtpserver",
        port => $smtpport,
        ssl  => 1,
        sasl_username => "$smtpuser",
        sasl_password => "$smtppassword",
        debug => 1,
        timeout => 5,
);
        my $radiusUser = $RAD_REQUEST{'User-Name'};
        my $radiusNas = $RAD_REQUEST{'NAS-IP-Address'};
        my $radiusFail = $RAD_REQUEST{'Module-Failure-Message'};
        my $radiusNasi = $RAD_REQUEST{'NAS-Identifier'};
my $email = Email::Simple->create(
        header => [
        To      => "$RAD_PERLCONF{'smtp'}->{'admin_email'}",
        From    => "$RAD_PERLCONF{'smtp'}->{'sender_email'}",
        Subject => "$RAD_PERLCONF{'smtp'}->{'subject'}",
],
        body => "Failed authentication from $radiusUser on $radiusNas ( $radiusNasi ) $radiusFail",
);

try {

&radiusd::log(L_DBG, '-=====================FAILED AUTH Send email to admin=======================-'.$_);
sendmail($email, { transport => $transport });

}
catch {
die "Error Email Sending: $_";
&radiusd::log(L_DBG, '-=====================FAILED AUTH=======================-'.$_);

};
}



# Function to handle authorize
sub authorize {
&cache_expiration();

&radiusd::log(L_DBG, '-=======================Authorize=======================-');
        log_request_attributes();
	&check_in_cache();
}


sub authenticate {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Authenticate====================-');
        log_request_attributes();
	&check_in_cache();
}


# Function to handle preacct
sub preacct {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Preacct====================-');
        log_request_attributes();
}


# Function to handle accounting
sub accounting {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Post_auth====================-');
        log_request_attributes();
}


# Function to handle pre_proxy
sub pre_proxy {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Pre_proxy====================-');
        log_request_attributes();
}

# Function to handle post_proxy
sub post_proxy {
&radiusd::log(L_DBG, '-=======================Post_proxy====================-');
        log_request_attributes();

}

# Function to handle post_auth
sub post_auth {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Post_auth====================-');
log_request_attributes();
my $msgs=$RAD_REQUEST{'Module-Failure-Message'};
#= $RAD_REQUEST{''};
if ( $msgs ne ''  ) {
&radiusd::log(L_INFO, "POST AUTH FAIL");
&failed_auth();
return RLM_MODULE_REJECT;
}
else {
&radiusd::log(L_INFO, "POST AUTH OK insert to cache");
&insert_to_cache();
return RLM_MODULE_OK;
}
}


# Function to handle detach
sub detach {
&cache_expiration();
&radiusd::log(L_DBG, '-=======================Detach====================-');
       log_request_attributes();
}



sub dbConnect {
&radiusd::log(L_DBG, '-=======================Connect to the Database====================-');

        my $dbHost              = $RAD_PERLCONF{'db'}->{'host'};
        my $dbName              = $RAD_PERLCONF{'db'}->{'name'};
        my $dbUsername  = $RAD_PERLCONF{'db'}->{'user'};
        my $dbPassword  = $RAD_PERLCONF{'db'}->{'password'};

my $dbh = DBI->connect("DBI:mysql:database=$dbName;host=$dbHost", $dbUsername, $dbPassword);
 return $dbh;
};

sub check_in_cache {
&radiusd::log(L_DBG, '-=======================Check that user is present in cache ====================-');

        $dbh=&dbConnect();

        my $radiusUserPassword = $RAD_REQUEST{'User-Password'};
        my $username = $RAD_REQUEST{'User-Name'};

        my $query = $dbh->prepare("SELECT * FROM cached_users WHERE username=? LIMIT 1");

        $query->execute($username);

        my $result = $query->fetchrow_arrayref();

        my $password = @$result[1];
	
        $query->finish();

        $dbh->disconnect();


        if ($password eq $radiusUserPassword) {
        &radiusd::log(L_DBG, '-=======================User is present in cache Fininsh====================-');
		$RAD_REPLY{'Auth-Type'}='Perl';
                return RLM_MODULE_OK;

        }
        else {

        &radiusd::log(L_DBG, "-=======================User isn't present in cache ====================-");
              return RLM_MODULE_NOOP;

        }
}

sub cache_expiration {
        &radiusd::log(L_DBG, '-=======================Check cache expiration====================-');

        log_request_attributes();

        $dbh=&dbConnect();

        my $query = $dbh->prepare("delete from cached_users where timestamp < (NOW() - INTERVAL $ENV{'CACHE_TIME'} MINUTE)");

        $query->execute();

        $query->finish();

        $dbh->disconnect();

        return RLM_MODULE_NOOP;
}


sub insert_to_cache {
        &radiusd::log(L_DBG, '-=======================Insert user to the cache====================-');

	$username=$RAD_REQUEST{'User-Name'};
	$password=$RAD_REQUEST{'User-Password'};
        log_request_attributes();
        $dbh=&dbConnect();
        my $query=$dbh->prepare("INSERT INTO cached_users(username,password) VALUES (?,?)");
        $query->execute($username,$password);
        $query->finish();
        $dbh->disconnect();
        return RLM_MODULE_OK;
}


sub log_request_attributes {
        # log all request data for debug
        for (keys %RAD_REQUEST) {
        &radiusd::log(L_DBG, "RAD_REQUEST: $_ = $RAD_REQUEST{$_}");
        }
        for (keys %RAD_CHECK) {
        &radiusd::log(L_DBG, "RAD_CHECK: $_ = $RAD_CHECK{$_}");
        }
        for (keys %RAD_PERLCONF) {
        &radiusd::log(L_DBG, "RAD_PERLCONF: $_ = $RAD_PERLCONF{$_}");
        }
        for (keys %RAD_CONFIG) {
        &radiusd::log(L_DBG, "RAD_CONFIG: $_ = $RAD_CONFIG{$_}");
        }
}

