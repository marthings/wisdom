package Wisdom::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $self = shift;
	my @categories = $self->db->categories->starred;
	my @articles = $self->db->articles->starred;

	$self->stash(
		categories => $self->_get_starred_categories,
		articles => $self->_get_starred_articles);

	$self->render(template => 'root/index');
}

sub _get_starred_categories {
	my $self = shift;
	my @categories = $self->db->categories->search(
		{ star => 1 }, { columns => [qw(slug title)] });

	my $result = undef;

	if (@categories) {
		$result = [];

		for my $c (@categories) {
			push @$result, {
				slug => $c->slug,
				title => $c->title,
			};
		}
	}

	$result;
}

sub _get_starred_articles {
	my $self = shift;
	my @articles = $self->db->articles->search(
		{ star => 1 }, { columns => [qw(slug title)] });

	my $result = undef;

	if (@articles) {
		$result = [];

		for my $c (@articles) {
			push @$result, {
				slug => $c->slug,
				title => $c->title,
			};
		}
	}

	$result;
}

1;
