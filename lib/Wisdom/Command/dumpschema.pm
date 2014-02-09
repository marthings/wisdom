package Wisdom::Command::dumpschema;
use Mojo::Base 'Mojolicious::Command';
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

has description => "Dump Wisdom database schema.\n";
has usage       => "usage: $0 dumpschema\n";

sub run {
	my $self = shift;
	my $config = $self->app->db_config;

	my $force = undef;
	my $debug = undef;

	for (@_) {
		if ($_ eq '--force') {
			$force = 1;
		}

		$force = 1 if $_ eq '--force';
		$debug = 1 if $_ eq '--debug';
	}

	make_schema_at(
		'Wisdom::Schema',
		{
			debug => $debug,
			dump_directory => './lib',
			components => [
				'InflateColumn::DateTime',
			],
			overwrite_modifications	=> $force,
		},
		[
			$config->{dsn},
			$config->{username},
			$config->{password},
			$config->{options},
		]
	);
}

1;
__END__

=encoding utf8

=head1 NAME

Wisdom::Command::dumpschema

=head1 SYNOPSIS

  ./script/wisdom dumpschema [--debug] [--force]

=head1 DESCRIPTION

L<Wisdom::Command::dumpschema> dumps the database schema.

If --force is present any modifications to the schema files will be
overwritten.

Debugging will be enabled if --debug is specified.

=head1 METHODS

=head2 run

Executes the command.

=head1 COPYRIGHT

Copyright (C) 2014 Per Edin.

=head1 AUHTOR

Per Edin - C<info@peredin.com>

=head1 SEE ALSO

L<Wisdom>

=cut
