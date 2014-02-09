package Wisdom::Command::installdb;
use Mojo::Base 'Mojolicious::Command';

has description => "Installs the Wisdom DB\n";
has usage       => "usage: $0 installdb\n";

sub run {
	my $self = shift;
	my $db = $self->app->db;

	say "Installing Wisdom database...";

	$db->deploy({
		quote_table_names => 0,
		quote_field_names => 0,
	});
}

1;
__END__

=encoding utf8

=head1 NAME

Wisdom::Command::installdb

=head1 SYNOPSIS

  ./script/wisdom installdb

=head1 DESCRIPTION

L<Wisdom::Command::installdb> installs an empty Wisdom database. The
database must be properly configured in the application configuration
file and the database must exist.

=head1 ATTRIBUTES

=head2 description

Returns a description about this command.

=head2 usage

Returns a string describing how to use this command.

=head1 METHODS

=head2 run

Executes the command.

=head1 COPYRIGHT

Copyright (C) 2014 Per Edin.

=head1 AUTHOR

Per Edin - C<info@peredin.com>

=head1 SEE ALSO

L<Wisdom>

=cut
