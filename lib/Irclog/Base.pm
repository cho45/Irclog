package Irclog::Base;

use utf8;
use strict;
use warnings;
use parent qw(Exporter::Lite);

use Router::Simple;
use Try::Tiny;

use Plack::Session;

use Irclog::Config;
use Irclog::Request;
use Irclog::Response;
use Irclog::Exception;
use Irclog::Views;

our @EXPORT = qw(config route throw);

our $router = Router::Simple->new;

sub throw (%) { Irclog::Exception->throw(@_) }
sub route ($$) { $router->connect(shift, { action => shift }) }

sub new {
	my ($class, $env) = @_;
	my $req = Irclog::Request->new($env);
	my $res = Irclog::Response->new(200);

	bless {
		req => $req,
		res => $res,
	}, $class;
}

sub before_dispatch {
	my ($r) = @_;
	$r->res->header('X-Frame-Options'  => 'DENY');
	$r->res->header('X-XSS-Protection' => '1');
}

sub after_dispatch {
	my ($r) = @_;
}

sub run {
	my ($r) = @_;
	try {
		my ($dest, $route) = $router->routematch($r->req->env);
		if ($dest) {
			my $action = delete $dest->{action};
			$r->req->path_parameters(%$dest);

			$r->before_dispatch;

			if (ref($action) eq 'CODE') {
				$action->(local $_ = $r);
			} else {
				my ($module, $method) = split /\s+/, $action;
				$module->use or die $@;
				$method ||= 'default';
				$module->$method($r);
			}
		} else {
			throw code => 404, message => 'Action not Found';
		}
	} catch {
		if (try { $_->isa('Irclog::Exception') }) {
			$r->res->code($_->{code});
			$r->res->header('X-Message' => $_->{message}) if $_->{message};
			$r->res->header('Location' => $_->{location}) if $_->{location};
			$r->res->content_type('text/plain');
			$r->res->content($_->{message});
		} else {
			die $_;
		}
	} finally {
		$r->after_dispatch;
	};

	$r;
}

sub req { $_[0]->{req} }
sub res { $_[0]->{res} }

sub session {
	$_[0]->{session} //= do {
		$_[0]->{req}->env->{'psgix.session'} ? Plack::Session->new($_[0]->{req}->env) : ''
	};
}

sub stash {
	$_[0]->{stash} ||= {};
	$_[0]->{stash};
}

sub user {
	my ($r) = @_;
	$r->session->get('oauth_hatena_user_info');
}

1;
__END__
