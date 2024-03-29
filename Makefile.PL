use inc::Module::Install;

name 'Irclog';
all_from 'lib/Irclog.pm';

requires 'Encode' => 2.42;

requires 'Plack';
requires 'Plack::Session';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::StaticShared';
requires 'Plack::Middleware::Auth::Basic';
requires 'Cache::LRU';

requires 'Router::Simple';

requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';

build_requires 'Test::Most';

WriteAll;
