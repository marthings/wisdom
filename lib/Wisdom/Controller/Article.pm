package Wisdom::Controller::Article;
use Mojo::Base 'Mojolicious::Controller';
use Text::Markdown;

sub lookup {
	my $self = shift;
	my $slug = $self->stash->{slug};
	my $article = $self->db->articles->by_slug($slug);

	return $self->render_not_found unless $article;

	$self->stash(article => $article);
}

sub show {
	my $self = shift;
	my $article = $self->stash->{article};

	die qq{Missing article in stash} unless $article;

	unless ($article->text_html) {
		$article->text_html(Text::Markdown::markdown($article->text));
		$article->update if $article->in_storage;
	}

	$self->stash(
		article_slug      => $article->slug,
		article_title     => $article->title,
		article_text_html => $article->text_html,
		category_slug     => $article->category->slug,
		category_title    => $article->category->title);

	$self->render(template => 'article/show');
}

sub edit {
	my $self = shift;
	my $article = $self->stash->{article};

	# Just render the form immediately on anything but POST.
	return $self->_render_edit_template($article)
		unless $self->req->method eq 'POST';

	# Delete article?
	if ($article && $self->param('delete-article')) {
		my $aslug = $article->slug;
		my $cslug = $article->category->slug;

		if ($article->delete) {
			$self->flash(success => 'Article successfully deleted.');
			$self->redirect_to('category.show', { slug => $cslug });
			return;
		}

		$self->validation->error('delete' => [ 'failed' ]);
		$self->redirect_to('article.edit', { slug => $aslug });
		return;
	}

	my $validation = $self->validation;
	$validation->required('article_slug')
		->size(1, 128)
		->like(qr/^[0-9a-z-]+$/);
	$validation->required('article_title')->size(1, 128);
	$validation->required('article_text');
	$validation->required('article_category');
	$validation->optional('article_starred');

	if ($validation->param('article_slug')) {
		# Only perform this check if we have a slug.
		$validation->error('article_slug' => [ 'unique' ])
			unless $self->db->articles
				->exclude_id($article ? $article->id : undef)
				->is_unique_slug($validation->param('article_slug'));
	}

	my $category_id = $validation->param('article_category');
	my $category = $self->db->categories->by_id($category_id)
		|| $validation->error(article_category => [ 'invalid' ]);

	return $self->_render_edit_template($article) if $validation->has_error;

	my $creating = $article ? 0 : 1;
	$article ||= $self->db->articles->new_result({});

	$article->slug($validation->param('article_slug'));
	$article->title($validation->param('article_title'));
	$article->text($validation->param('article_text'));
	$article->text_html(undef);
	$article->category($category);
	$article->star($validation->param('article_starred') ? 1 : 0);

	$article->insert_or_update;
	
	$self->flash(success => $creating ? 'Article successfully created.'
                                      : 'Article successfully saved.');
	$self->redirect_to('article.show', { slug => $article->slug });
}

sub _render_edit_template {
	my ($self, $article) = @_;

	$self->stash(
		article_slug     => $article ? $article->slug : '',
		article_title    => $article ? $article->title : '',
		article_text     => $article ? $article->text : '',
		article_category => $article ? $article->category->id : 0,
		article_starred  => $article ? $article->star : 0,
		categories       => scalar $self->_select_categories);

	$self->render(template => 'article/edit',
	              creating => $article ? 0 : 1);
	1;
}

sub _select_categories {
	my $self = shift;
	my @all = $self->db->categories->search(undef,
		{ columns => [qw(id title)]})->all;
	my @result = ();
	for my $i (@all) {
		push @result, [ $i->title, $i->id ];
	}
	return wantarray ? @result : \@result;
}

1;
