package Irclog::Login;

use utf8;
use strict;
use warnings;

use OAuth::Lite::Consumer;
use JSON::XS;

use Irclog;

sub hatena {
	my ($class, $r) = @_;

	my $consumer = OAuth::Lite::Consumer->new(
		consumer_key       => config->param("hatena_consumer_key"),
		consumer_secret    => config->param("hatena_consumer_secret"),
		site               => q{https://www.hatena.com},
		request_token_path => q{https://www.hatena.com/oauth/initiate},
		access_token_path  => q{https://www.hatena.com/oauth/token},
		authorize_path     => q{https://www.hatena.ne.jp/oauth/authorize},
	);

	my $verifier = $r->req->param('oauth_verifier');

	unless ($verifier) {
		my $request_token = $consumer->get_request_token(
			callback_url => $r->req->uri.q(),
			scope        => 'read_public',
		) or throw(code => 500, message => $consumer->errstr);

		$r->session->set(oauth_hatena_request_token => +{ token => $request_token->token, secret => $request_token->secret });
		$r->session->set(location => $r->req->param('location'));
		throw(code => 302, message => "verifier is required", location => $consumer->url_to_authorize(token => $request_token));
	}

	my $access_token = $consumer->get_access_token(
		token    => OAuth::Lite::Token->new( %{ $r->session->get('oauth_hatena_request_token') }),
		verifier => $verifier,
	) or throw(code => 500, message => $consumer->errstr);

	$r->session->remove('oauth_hatena_request_token');

	my $my = $consumer->request(
		method => 'POST',
		url    => 'http://n.hatena.com/applications/my.json',
		token  => $access_token,
	);
	$my->is_success or throw(code => 500, message => 'Failed to retrieve user name.');

	$r->session->set('oauth_hatena_user_info', decode_json($my->decoded_content || $my->content));

	$r->res->redirect( $r->session->remove('location') || '/' );
}


1;
__END__
