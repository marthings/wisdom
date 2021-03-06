package Wisdom;

=head1 NAME

Wisdom - Simple knowledge base system

=head1 VERSION

0

=head1 DESCRIPTION

Wisdom is a very simple knowledge base system.

=cut

use Mojo::Base 'Mojolicious';
use Wisdom::Schema;

our $VERSION = '0';

=head1 ATTRIBUTES

=head2 styles

This attribute holds an array of extra stylesheets passed to AssetPack.

=cut

has styles => sub { [] };

=head2 scripts

This attribute holds an array of extra scripts passed to AssetPack.

=cut

has scripts => sub { [] };

=head2 db_config

This attribute holds the database configuration.

=cut

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

=head2 db

This attribute holds the database connection.

=cut

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

=head1 METHODS

=head2 startup

This method will run once at server start.

=cut

sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');
	$config->{name} ||= 'Wisdom';

	$self->secrets($config->{secrets}
		|| die qq{'secrets' is required in config file\n});

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

=head2 _init_menus

This method will initialize the menus.

=cut

sub _init_menus {
	my $self = shift;

	$self->plugin('Wisdom::Plugin::Menus');

	my $main = {
		template => 'components/menus/main',
		items => [
			{
				link  => 'category.list',
				text  => 'Browse',
				order => 10,
			},
			{
				link  => 'category.create',
				text  => 'New Category',
				order => 20,
			},
			{
				link  => 'article.create',
				text  => 'New Article',
				order => 21,
			},
		],
	};

	$self->menu->create(
		main => $main,
	);
}

=head2 _init_routes

This method will initialize the routes.

=cut

sub _init_routes {
	my $self = shift;
	my $r = $self->routes;

	$r->namespaces(['Wisdom::Controller']);
	$r->add_shortcut(form => sub { shift->any([qw(GET POST)], @_) });

	$r->get('/')->to('root#index')->name('index');

	$r->get('/browse')->to('category#list')->name('category.list');
	$r->form('/browse/create-category')->to('category#edit')->name('category.create');
	$r->form('/articles/new')->to('article#edit')->name('article.create');

	$r->get('/search')->to('search#perform_query')->name('search');

	my $categories_r = $r->under('/browse/:slug')->to('category#lookup');
	$categories_r->get('/')->to('category#show')->name('category.show');
	$categories_r->form('/edit')->to('category#edit')->name('category.edit');

	my $articles_r = $r->under('/articles/:slug')->to('article#lookup');
	$articles_r->get('/')->to('article#show')->name('article.show');
	$articles_r->form('/edit')->to('article#edit')->name('article.edit');
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Per Edin.

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGMENT, IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name(s) of the above copyright
holders shall not be used in advertising or otherwise to promote the
sale, use or other dealings in this Software without prior written
authorization from the copyright holders.

=head1 AUTHOR

Per Edin - C<info@peredin.com>

=cut

1;
