	# This package contains all classfields
	#
	# class, { attr => ..	# calls Class::Maker::fields::attr

package Class::Maker::Basic::Fields;

use Carp;

sub configure
{
	my $args = shift;

	my $reflex = shift;

	Class::Maker::_make_method( 'new', exists $args->{ctor} ? $args->{ctor} : 'new' );

	if( exists $args->{explicit} )
	{
		$explicit = $args->{explicit};

		::carp "EXPLICIT $explicit" if $DEBUG;
	}

	# dtor is missing here
}

sub persistance
{
	my $args = shift;

	my $reflex = shift;

	no strict 'refs';
}

sub isa
{
	my $args = shift;

	my $reflex = shift;

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

	my $reflex = shift;

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

	my $reflex = shift;

	foreach my $attr ( keys %$args )
	{
		::carp "\tsetting default for $attr..\n" if $DEBUG;
	}
}

sub attribute
{
	my $args = shift;

	my $reflex = shift;

	my $prefix = shift || '';

		if( exists $reflex->{configure}->{private}->{prefix} && $prefix )
		{
			$prefix = $reflex->{configure}->{private}->{prefix};
		}

		foreach my $type ( keys %$args )
		{
			::carp "\tkey: $type\n" if $DEBUG;

			my @attributes = ( ref( $args->{$type} ) eq 'HASH' ) ? keys %{$args->{$type}} : @{ $args->{$type} };

			my $cnt = 0;

			foreach my $name ( @attributes )
			{
				my $pre = $prefix;

				my $na = $name;

					# check the <attribute> features (only in non private sections

				unless( $prefix )
				{
					if( $na =~ /^</ )
					{
						$pre = ( exists $reflex->{configure}->{private}->{prefix} ) ? $reflex->{configure}->{private}->{prefix} : '_';

						$na =~ s/[<>]//g;

								# put this method to the private section, just for the reflection

						unless( ( ref( $args->{$type} ) eq 'HASH' ) )
						{
							$reflex->{private}->{$type} = [] unless exists $reflex->{private}->{$type};

							push @{ $reflex->{private}->{$type} }, $na;

								# we have to delete this method from the attribute/attr/public section.

							splice @{ $args->{$type} }, $cnt, 1;

							delete $args->{$type} unless scalar @{ $args->{$type} };
						}
						else
						{
							$reflex->{private}->{$type}->{$na} = $args->{$type}->{$name};

								# we have to delete this method from the attribute/attr/public section.

							delete $args->{$type}->{$name};

							delete $args->{$type} unless keys %{ $args->{$type} };
						}
					}
				}

				Class::Maker::_make_method( $type, $na, $pre );

				$cnt++;
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

sub private
{
	attribute( @_, '_' );
}

sub privat
{
	private( @_ );
}

sub automethod
{
	my $args = shift;

	my $reflex = shift;

	::carp join( ',', @$args ), "\n" if $DEBUG;
}

sub has
{
	my $args = shift;

	my $reflex = shift;

	foreach ( keys %$args )
	{
		::carp "\tkey: $_\n" if $DEBUG;
	}
}

1;
