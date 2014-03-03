package Wisdom::Controller::Category;
use Mojo::Base 'Mojolicious::Controller';
use Text::Markdown 'markdown';

sub list {
	my $self = shift;
	my @categories = $self->db->categories->all;

	if (@categories) {
		my @stash_categories = ();
		for my $category (@categories) {
			push @stash_categories, {
				slug  => $category->slug,
				title => $category->title
			};
		}
		$self->stash(categories => \@stash_categories);
	}

	$self->render(template => 'category/list');
}

sub lookup {
	my $self = shift;
	my $slug = $self->stash->{slug};
	my $category = $self->db->categories->by_slug($slug);

	return $self->render_not_found unless $category;

	$self->stash(category => $category);
}

sub show {
	my $self = shift;
	my $slug = $self->stash->{slug};
	my $category = $self->db->categories->by_slug($slug);

	return $self->render_not_found unless $category;

	my @articles = $category->articles->all;

	if (@articles) {
		my @stash_articles = ();
		for my $article (@articles) {
			push @stash_articles, {
				slug  => $article->slug,
				title => $article->title
			};
		}
		$self->stash(articles => \@stash_articles);
	}

	$self->stash(category_slug => $category->slug,
	             category_title => $category->title);
	$self->render(template => 'category/show');
}

sub edit {
	my $self = shift;
	my $category = $self->stash->{category};

	# Just render the form immediately on anything but POST.
	return $self->_render_edit_template($category)
		unless $self->req->method eq 'POST';

	# Delete category?
	if ($category && $self->param('delete-category')) {
		my $slug = $category->slug;

		if ($category->delete) {
			$self->flash(success => 'Category successfully deleted.');
			$self->redirect_to('category.list');
			return;
		}

		$self->validation->error('delete' => [ 'failed' ]);
		$self->redirect_to('category.edit', { slug => $slug });
		return;
	}

	my $validation = $self->validation;
	$validation->required('category_slug')
		->size(1, 128)
		->like(qr/^[0-9a-z-]+$/);
	$validation->required('category_title')->size(1, 128);
	$validation->optional('category_starred');

	if ($validation->param('category_slug')) {
		# Only perform this check if we have a slug.
		$validation->error('category_slug' => [ 'unique' ])
			unless $self->db->categories
				->exclude_id($category ? $category->id : undef)
				->is_unique_slug($validation->param('category_slug'));
	}

	return $self->_render_edit_template($category)
		if $validation->has_error;

	my $creating = $category ? 0 : 1;
	$category ||= $self->db->categories->new_result({});

	$category->slug($validation->param('category_slug'));
	$category->title($validation->param('category_title'));
	$category->star($validation->param('category_starred') ? 1 : 0);

	$category->insert_or_update;
	
	$self->flash(success => $creating ? 'Category successfully created.'
                                      : 'Category successfully saved.');
	$self->redirect_to('category.show', { slug => $category->slug });
}

sub _render_edit_template {
	my ($self, $category) = @_;

	$self->stash(
		category_slug    => $category ? $category->slug : '',
		category_title   => $category ? $category->title : '',
		category_starred => $category ? $category->star : 0);

	$self->render(template => 'category/edit',
	              creating => $category ? 0 : 1);
	1;
}

1;
