package Irclog;

use strict;
use warnings;

use Irclog::Base;
use parent qw(Irclog::Base);

our @EXPORT = qw(config throw);

route "/" => sub {
	my $r = shift;

	$r->html('index.html');
};

route "/login/hatena" => "Irclog::Login hatena";

1;
