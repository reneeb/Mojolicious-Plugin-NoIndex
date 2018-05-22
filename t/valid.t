use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

get '/'      => \&render_index => 'index';
get '/test'  => \&render_index => 'test';
get '/third' => \&render_index => 'third';

my @tests = (
    {
        param    => { routes => { index => 1 } },
        requests => [
            {
                value => 'noindex',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
        ],
    },
    {
        param    => { routes => { index => 1, third => 1 } },
        requests => [
            {
                value => 'noindex',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { routes => { index => 'follow', third => 1, } },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { default => 'follow', routes => { index => 1 } },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
        ],
    },
    {
        param    => { default => 'follow', routes => { index => 1, third => 1 } },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'follow',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { default => 'follow', routes => { index => 'follow', third => 1, } },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { by_value => { noindex => [ 'index' ] } },
        requests => [
            {
                value => 'noindex',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
        ],
    },
    {
        param    => { by_value => { noindex => [ 'index', 'third' ] } },
        requests => [
            {
                value => 'noindex',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { by_value => { noindex => [ 'third' ], follow => ['index'] } },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                route => '/test',
                set   => 0,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { all_routes => 1 },
        requests => [
            {
                value => 'noindex',
                route => '/',
                set   => 1,
            },
            {
                value => 'noindex',
                route => '/test',
                set   => 1,
            },
            {
                value => 'noindex',
                route => '/third',
                set   => 1,
            },
        ],
    },
    {
        param    => { all_routes => 1, default => 'follow' },
        requests => [
            {
                value => 'follow',
                route => '/',
                set   => 1,
            },
            {
                value => 'follow',
                route => '/test',
                set   => 1,
            },
            {
                value => 'follow',
                route => '/third',
                set   => 1,
            },
        ],
    },
);

for my $test ( @tests ) {
    plugin 'NoIndex' => $test->{param};
    
    my $t = Test::Mojo->new;
    for my $request ( @{ $test->{requests} || [] } ) {
        my $value = $request->{value};

        if ( $request->{set} ) {
            $t->get_ok( $request->{route} )
              ->status_is(200)
              ->content_like( qr{<meta name="robots" content="$value">} );
        }
        else {
            $t->get_ok( $request->{route} )
              ->status_is(200)
              ->content_unlike( qr{<meta name="robots"} );
        }
    }
}

done_testing();

sub render_index {
    shift->render('index');
}

__DATA__
@@ index.html.ep
% layout 'default';

@@ layouts/default.html.ep
<html>
  <head>
  </head>
</html>
