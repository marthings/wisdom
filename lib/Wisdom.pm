package Wisdom;
use Mojo::Base 'Mojolicious';

has styles => sub { [] };

has scripts => sub { [] };

sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');
	$config->{name} ||= 'Wisdom';

	push @{$self->commands->namespaces}, 'Wisdom::Command';

	$self->_init_routes;

	# We initialize AssetPack as late as possible.
	$self->plugin('AssetPack');

	$self->asset('wisdom.css' => (
		'/css/jquery-ui-1.10.3.css',
		'/css/bootstrap.css',
		'/css/bootstrap-theme.css',
		'/css/font-awesome.css',

		@{$self->styles}
	));

	$self->asset('wisdom.js' => (
		'/js/jquery-1.11.0.js',
		'/js/jquery-ui-1.10.3.js',
		'/js/bootstrap.js',

		@{$self->scripts}
	));
}

sub _init_routes {
	my $self = shift;
	my $r = $self->routes;

	$r->namespaces(['Wisdom::Controller']);

	$r->get('/')->to('root#index')->name('index');
}

1;
