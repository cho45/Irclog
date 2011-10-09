# vim:ft=perl:
use strict;
use warnings;
use lib 'lib';
use lib glob 'modules/*/lib';

use UNIVERSAL::require;
use Path::Class;
use Plack::Builder;
use File::Spec;
use Cache::LRU;

use Plack::Middleware::Session;
use Plack::Session::State::Cookie;
use Plack::Session::Store::File;

use Data::MessagePack;

use Irclog;

my $session_dir = dir(config->param('session_dir'))->absolute;
$session_dir->mkpath;

builder {
	enable "Plack::Middleware::Static",
		path => qr{^/(images|js|css)/},
		root => config->root->subdir('static');

	enable "Plack::Middleware::ReverseProxy";
	enable "Plack::Middleware::Session",
		state => Plack::Session::State::Cookie->new,
		store => Plack::Session::Store::File->new(
			dir          => "$session_dir",
		)
	;

	sub {
		Irclog->new(shift)->run->res->finalize;
	};
};


