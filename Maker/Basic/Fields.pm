	# This package contains all classfields
	#
	# class, { attr => ..	# calls Class::Maker::fields::attr

package Class::Maker::Basic::Fields;

use Carp;

sub configure
{
	my $args = shift;

	Class::Maker::_make_method( [$args->{ctor}], 'new' ) if exists $args->{ctor};

	if( exists $args->{explicit} )
	{
		$explicit = $args->{explicit};

		carp "EXPLICIT $explicit" if $DEBUG;
	}

	# dtor is missing here
}

sub persistance
{
	my $args = shift;

	no strict 'refs';
}

sub isa
{
	my $args = shift;

		no strict 'refs';

			# Transform parent classes
			#
			# package My;
			#
			# .Class::Any # relative to the current package: My::Class::Any
			#
			# *Class::Any # relative to the current package: My::Class::Any

		map { s/^[\*\.]/${Class::Maker::cpkg}::/ } @$args;

		@{ "${Class::Maker::pkg}::ISA" } = @$args;
}

sub version
{
	my $args = shift;

	no strict 'refs';

	${ "${Class::Maker::pkg}::VERSION" } = shift @$args;
}

sub can
{
	#my $args = shift;

	#no strict 'refs';

	#my $varname = "${pkg}::CAN";

	#@{ $varname } = @$args;
}

sub default
{
	my $args = shift;

	foreach my $attr ( keys %$args )
	{
		carp "\tsetting default for $attr..\n" if $DEBUG;
	}
}

sub attribute
{
	my $args = shift;

	foreach my $type ( keys %$args )
	{
		carp "\tkey: $type\n" if $DEBUG;

			# check for non href and take the keys only

		if( ref( $args->{$type} ) eq 'HASH' )
		{
			Class::Maker::_make_method( [(keys %{$args->{$type}})], $type ) if keys %{$args->{$type}};

			#print "attribute HASH listing detected\n";
		}
		else
		{
			Class::Maker::_make_method( $args->{$type}, $type ) if scalar @{ $args->{$type} };
		}
	}
}

sub attr
{
	attribute( @_ );
}

sub public
{
	attribute( @_ );
}

sub privat
{
	attribute( @_ );
}

sub automethod
{
	my $args = shift;

	carp join( ',', @$args ), "\n" if $DEBUG;
}

sub has
{
	my $args = shift;

	foreach ( keys %$args )
	{
		carp "\tkey: $_\n" if $DEBUG;
	}
}

1;
