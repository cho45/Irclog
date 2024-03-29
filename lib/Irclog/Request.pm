package Irclog::Request;

use utf8;
use strict;
use warnings;
use parent qw(Plack::Request);
use Hash::MultiValue;
use Encode;

sub parameters {
	my $self = shift;

	$self->env->{'plack.request.merged'} ||= do {
		my $query = $self->query_parameters;
		my $body  = $self->body_parameters;
		my $path  = $self->path_parameters;
		Hash::MultiValue->new($path->flatten, $query->flatten, $body->flatten);
	};
}

sub path_parameters {
	my $self = shift;

	if (@_ > 1) {
		$self->{_path_parameters} = Hash::MultiValue->new(@_);
	}

	$self->{_path_parameters} ||= Hash::MultiValue->new;
}

sub is_xmlhttprequest {
	my ($self) = @_;
	my $requested_with = $self->header('X-Requested-With') || '';
	$requested_with eq 'XMLHttpRequest';
}

sub string_param {
	my ($self, $name) = @_;
	my $raw = $self->param($name);
	decode_utf8($raw);
}

1;
