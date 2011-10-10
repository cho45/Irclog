use strict;
use warnings;
use utf8;

use Test::More;

use Irclog::LogParser;

is_deeply +Irclog::LogParser->parse('00:03:43 <#twitter@twitter:@miyako> foobar'), {
	hour    => '00',
	minute  => '03',
	second  => '43',
	channel => '#twitter@twitter',
	nick    => 'miyako',
	message => 'foobar',
};

done_testing;
