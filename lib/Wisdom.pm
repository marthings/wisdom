package Wisdom;
use Mojo::Base 'Mojolicious';
use Wisdom::Schema;

has styles => sub { [] };

has scripts => sub { [] };

has db_config => sub {
	my $self = shift;
	my $config = $self->config->{database}
		|| die qq{database configuration is missing\n};

	die qq{'dsn' is missing from database configuration}
		unless $config->{dsn};

	$config->{username} ||= '';
	$config->{password} ||= '';
	$config->{options} ||= { };
	$config->{extras} ||= { };

	# Always enable AutoCommit.
	$config->{options}{AutoCommit} = 1;

	$config;
};

has db => sub {
	my $self = shift;
	my $config = $self->db_config;

	Wisdom::Schema->connect(
		$config->{dsn},
		$config->{username},
		$config->{password},
		$config->{options},
		$config->{extras},
	);
};

sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');
	$config->{name} ||= 'Wisdom';

	$self->_init_menus;

	push @{$self->commands->namespaces}, 'Wisdom::Command';

	$self->db; # make sure DB is always available.
	$self->helper(db => sub { shift->app->db; });

	$self->_init_routes;

	# We initialize AssetPack as late as possible.
	$self->plugin('AssetPack');

	$self->asset('wisdom.css' => (
		'/css/jquery-ui-1.10.3.css',
		'/css/bootstrap.css',
		'/css/bootstrap-theme.css',
		'/css/font-awesome.css',

		'/css/wisdom.scss',

		@{$self->styles}
	));

	$self->asset('wisdom.js' => (
		'/js/jquery-1.11.0.js',
		'/js/jquery-ui-1.10.3.js',
		'/js/bootstrap.js',

		@{$self->scripts}
	));
}

sub _init_menus {
	my $self = shift;

	$self->plugin('Wisdom::Plugin::Menus');

	my $main = {
		template => 'components/menus/main',
		items => [ ],
	};

	$self->menu->create(
		main => $main,
	);
}

sub _init_routes {
	my $self = shift;
	my $r = $self->routes;

	$r->namespaces(['Wisdom::Controller']);

	$r->get('/')->to('root#index')->name('index');
}

1;
