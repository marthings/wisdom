package Wisdom::Plugin::Menus;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream 'b';
use Carp;
use Wisdom::Plugin::Menus::Menu;

our $VERSION = '0.01';

sub register {
	my ($self, $app, $conf) = @_;

	$self->{menus} = {};

	$app->helper(menu => sub { $self });
	$app->helper(render_menu => sub { $self->render(@_) });
}

sub create {
	my $self = shift;

	my $values = ref $_[0] ? $_[0] : { @_ };
	for my $key (keys %$values) {
		my $menu_def = $values->{$key} || next;
		$self->{menus}{$key} = $self->_create_menu($menu_def);
	}
}

sub render {
	my ($self, $c, $handle) = @_;
	my $menu = $self->{menus}{$handle};

	return b qq{<!-- no such menu "$handle" -->} unless $menu;

	return $menu->render($c);
}

sub _create_menu {
	my ($self, $menu) = @_;

	return Wisdom::Plugin::Menus::Menu->new(
		template => $menu->{template},
		items => $menu->{items} || []
	);
}

1;
