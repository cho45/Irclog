package Irclog::Views;

use utf8;
use strict;
use warnings;

use Exporter::Lite;
use Text::Xslate;
use JSON::XS;
use Encode;

use Irclog::Config;

our @EXPORT = qw(html json);

my $Xslate = Text::Xslate->new(
	syntax => 'TTerse',
	module => [
		'Text::Xslate::Bridge::TT2Like' 
	],
	path  => [
		config->root->subdir('templates')
	],
);

sub html {
	my ($r, $name, $vars) = @_;
	$vars = {
		r => $r,
		%{ $r->stash },
		%{ $vars || {} },
	};

	my $html = $Xslate->render($name, $vars);

	$r->res->content_type('text/html; charset=utf-8');
	$r->res->content(encode_utf8 $html);
}

sub json {
	my ($r, $object, %opts) = @_;
	if ($r->req->is_xmlhttprequest && !$opts{insecure}) {
		Irclog::Exception->throw(code => 400, message => "You must send X-Requested-With: XMLHttpRequest header.");
	}

	$r->res->content_type('application/json; charset=utf-8');
	$r->res->content(encode_json $object);
}

1;
__END__
