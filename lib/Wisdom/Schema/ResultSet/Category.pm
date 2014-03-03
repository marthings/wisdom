package Wisdom::Schema::ResultSet::Category;

use Modern::Perl;
use base 'DBIx::Class::ResultSet';

sub search_slug {
	shift->search({ slug => pop });
}

sub search_id {
	shift->search({ id => pop });
}

sub exclude_id {
	my ($rs, $id) = @_;
	return $rs unless $id;
	$rs->search({ id => { '!=', $id }});
}

sub starred {
	shift->search({ star => 1});
}

sub by_slug {
	shift->search_slug(pop)->single;
}

sub by_id {
	shift->search_id(pop)->single;
}

sub is_unique_slug {
	return 0 == shift->search_slug(pop)->count;
}

1;
