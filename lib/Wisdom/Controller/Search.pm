package Wisdom::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub perform_query {
	my $self = shift;
	my $query = $self->param('query');

	if ($query) {
		$self->stash(
			categories => $self->_search_categories($query),
			articles => $self->_search_articles($query));
	}

	$self->render(template => 'search/list');
}

=head2 _search_categories

Searches categories and returns results as a reference to an array of
hashes. undef is returned if nothing was found.

=cut

sub _search_categories {
	my ($self, $query) = @_;

	my @categories = $self->db->categories->search(
		{
			-or => [ slug  => { 'LIKE', qq{%$query%} },
			         title => { 'LIKE', qq{%$query%} } ]
		},
		{ columns => [qw(slug title)] }
	);

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

=head2 _search_articles

Searches articles and returns results as a reference to an array of
hashes. undef is returned if nothing was found.

=cut

sub _search_articles {
	my ($self, $query) = @_;

	my @articles = $self->db->articles->search(
		{
			-or => [ slug  => { 'LIKE', qq{%$query%} },
			         title => { 'LIKE', qq{%$query%} },
			         text  => { 'LIKE', qq{%$query%} } ]
		},
		{ columns => [qw(slug title)] }
	);

	my $result = undef;

	if (@articles) {
		$result = [];

		for my $a (@articles) {
			push @$result, {
				slug => $a->slug,
				title => $a->title,
			};
		}
	}

	$result;
}

1;
