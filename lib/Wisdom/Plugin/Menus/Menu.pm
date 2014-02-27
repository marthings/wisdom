package Wisdom::Plugin::Menus::Menu;
use Mojo::Base -base;
use Mojo::ByteStream 'b';

has template => sub { return ''; };

has items => sub { return []; };

sub process {
	my ($self, $c) = @_;
	my @items = ();

	for my $i (@{$self->items}) {
		next if ref $i->{condition} eq 'CODE'
			&& !$i->{condition}($c);

		my $link = ref $i->{link} eq 'CODE'
			? $i->{link}($c)
			: $c->url_for($i->{link})->to_abs;

		push @items, {
			text => $i->{text},
			link => $link,
			class => [],
			_order => ($i->{order} // 0)
		};
	}

	my @sorted = sort { $a->{_order} <=> $b->{_order} } @items;
	return \@sorted;	
}

sub render {
	my ($self, $c) = @_;

	my $items = $self->process($c);

	return undef unless @$items > 0;

	return b "<!-- no menu template specified! -->"
		unless $self->template;

	return $c->render(
		template => $self->{template},
		items => $items,
		partial => 1);
}

1;
