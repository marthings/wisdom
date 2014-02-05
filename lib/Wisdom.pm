package Wisdom;
use Mojo::Base 'Mojolicious';

sub startup {
	my $self = shift;

	push @{$self->commands->namespaces}, 'Wisdom::Command';

	$self->_init_routes;
}

sub _init_routes {
	my $self = shift;
	my $r = $self->routes;

	$r->namespaces(['Wisdom::Controller']);

	$r->get('/')->to('root#index')->name('index');
}

1;
