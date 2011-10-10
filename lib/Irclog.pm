package Irclog;

use strict;
use warnings;

use Irclog::Base;
use parent qw(Irclog::Base);

use IO::File;
use Time::Piece;
use Path::Class;
use Irclog::LogParser;
use Encode;

our @EXPORT = qw(config throw);

route "/" => sub {
	my $r = shift;

	$r->stash->{auth} = [ $r->require_auth ];

	$r->html('index.html');
};

route "/log/:channel/:date" => sub {
	my $r = shift;
	my ($auth) = $r->require_auth($r->req->string_param('channel'));

	my $file;
	if ($r->req->param('date') eq 'recent') {
		$file = [ sort { $b cmp $a } glob config->param('irclog') . "/*.txt" ]->[0];
	} elsif ($r->req->param('date') =~ m{^(\d\d\d\d)-(\d\d)-(\d\d)$}) {
		$file = config->param('irclog') . "/$1-$2-$3.txt";
	} else {
		throw(code => 302, message => 'Invalid date format', location => '/');
	}

	my $date = Time::Piece->strptime(file($file)->basename, "%Y-%m-%d.txt");
	$r->stash->{channel} = $auth;
	$r->stash->{prev_date} = $date - (60 * 60 * 24);
	$r->stash->{date} = $date;
	$r->stash->{next_date} = $date + (60 * 60 * 24);

	my $fh = IO::File->new($file);
	if (defined $fh) {
		my $log = [];
		while (defined(my $line = <$fh>)) {
			my $line = Irclog::LogParser->parse($line);
			next unless $line->{channel};
			$line->{channel} = decode_utf8 $line->{channel};
			next unless $line->{channel} eq "#$auth";
			$line->{message} = decode_utf8 $line->{message};
			unshift @$log, $line;
		}
		$r->stash->{log} = $log;
		$fh->close;
	} else {
		$r->stash->{log} = [];
	}

	$r->html('log.html');
};

route "/login/hatena" => "Irclog::Login hatena";

1;
