package Mojolicious::Plugin::NoIndex;

# ABSTRACT: add meta tag to HTML output to define a policy for robots

use Mojo::Base 'Mojolicious::Plugin';

use Carp qw(croak);

our $VERSION = '0.01';

sub register {
    my ($self, $app, $config) = @_;

    if ( !$config || !%{$config} ) {
        $config = { all_routes => 1 };
    }

    my $default_value = $config->{default} // 'noindex';

    my %routes;

    for my $route_name ( keys %{ $config->{routes} || {} } ) {
        my $value = $config->{routes}->{$route_name};
        $value    = $default_value if $value eq '1';

        $routes{$route_name} = $value;
    }

    for my $value ( keys %{ $config->{by_value} || {} } ) {
        for my $route_name ( @{ $config->{by_value}->{$value} || [] } ) {
            $routes{$route_name} = $value;
        }
    }

    $app->hook(
        after_render => sub {
            my ($c, $content, $format) = @_;

            return if !$format;
            return if $format ne 'html';

            my $route = $c->current_route;
            return if !$routes{$route} && !$config->{all_routes};

            my $value = $routes{$route} // $default_value;

            $$content =~ s{<head>\K}{<meta name="robots" content="$value">};
        }
    );
}

1;
__END__

=encoding utf8

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('NoIndex');

  # Mojolicious::Lite
  plugin 'NoIndex';

  # to allow sending referrer information to the origin
  plugin 'NoIndex' => { content => 'same-origin' };

=head1 DESCRIPTION

L<Mojolicious::Plugin::NoIndex> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::NoIndex> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head2 HOOKS INSTALLED

This plugin adds one C<after_render> hook to add the <meta> tag.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut
