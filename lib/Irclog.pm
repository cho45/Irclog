package Irclog;

use strict;
use warnings;

use Irclog::Base;
use parent qw(Irclog::Base);

our @EXPORT = qw(config);

route "/" => sub {
	$_->res->content('Hello, World!');
};

1;
