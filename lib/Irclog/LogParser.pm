package Irclog::LogParser;

use utf8;
use strict;
use warnings;

use Encode;

sub parse {
	my ($class, $msg, %opts) = @_;
	my $base = $opts{base};
	if ($msg =~ m{^(?<hour>\d\d):(?<minute>\d\d):(?<second>\d\d) <(?<channel>[^:]+):@?(?<nick>[^>]+)> (?<message>.+)}) {
		+{ %+ };
	} else {
		()
	}
}


1;
__END__
