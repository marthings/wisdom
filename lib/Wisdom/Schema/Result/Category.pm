use utf8;
package Wisdom::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wisdom::Schema::Result::Category

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<category>

=cut

__PACKAGE__->table("category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'category_id_seq'

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 star

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "category_id_seq",
  },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "star",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<category_slug_key>

=over 4

=item * L</slug>

=back

=cut

__PACKAGE__->add_unique_constraint("category_slug_key", ["slug"]);

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Wisdom::Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Wisdom::Schema::Result::Article",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-27 16:33:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ytxrGIqpDWe/Gi2j53envQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
