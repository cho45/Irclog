package Irclog::Config;

use utf8;
use strict;
use warnings;
use Config::ENV 'PLACK_ENV', export => 'config';
use Path::Class;
use constant root => dir(".")->absolute;

common +{
	appname => 'irclog',
	session_dir => '/tmp/irclog.session',
};

config development => do {
	my $file   = root->file("development.conf");
	my $config = do "$file";
	unless ($config) {
		die "Couldn't parse $file: $@" if $@;
		die "Couldn't do $file: $!"    unless defined $config;
		die "Couldn't run $file: $!"   unless $config;
	}
	$config;
};

config staging => {
};

config production => {
};

1;
__END__
