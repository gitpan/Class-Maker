# Author: Murat Uenalan (murat.uenalan@charite.de)
#
# Copyright (c) 2001 Murat Uenalan. All rights reserved.
#
# Note: This program is free software; you can redistribute
#
# it and/or modify it under the same terms as Perl itself.

package Class::Maker::Basic::Reflection;

require 5.005_62; use strict; use warnings;

our $VERSION = '0.01';

use Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(reflect classes) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

use IO::Extended ':all';

sub reflect
{
	my $class = shift;

		$class = ref( $class ) || $class;

		if( my $reflection = ${ Class::Maker::findclass( $class ) } )
		{
			my $mlist = find_methods( $class );

			$reflection->{ methods } = $mlist if @{$mlist} > 0;

			my $part = shift;

			return $part ? $reflection->{$part} : $reflection;
		}

return undef;
}

=head1 Function B<classes>

	classes( fakultativ $scalref_mainpackage, [ $package ], .. );

=head1 Purpose

	Traverses the symbol table and find "reflectable" classes.

	Returns a list of hash references containing:

		"package_identifier" => $HREF_CLASS_HASH

	Meaning it gets references to the reflection of the class.

	{ 'main::MyClass' => $href_myclass }, { 'main::YourClass' => $href_yclass }, ..

=cut

sub classes
{
	no strict 'refs';

	my @found;

	my $path = shift if @_ > 1;

	foreach my $pkg ( @_ )
	{
		next unless $pkg =~ /::$/;

		$path .= $pkg;

		if( $path =~ /(.*)::$/ )
		{
			my $clean_path = $1;

			if( $path ne 'main::' )
			{
				if( my $href_cls = reflect( $clean_path ) )
				{
					push @found, { $clean_path => $href_cls };
				}
			}

			foreach my $symbol ( sort keys %{$path} )
			{
				if( $symbol =~ /::$/ && $symbol ne 'main::' )
				{
					push @found,  classes( $path, $symbol );
				}
			}
		}
	}

return @found;
}

sub find_methods
{
	my $class = shift;

		my $methods = [];

		no strict 'refs';

		foreach my $pkg ( $class.'::' )
		{
			foreach ( sort keys %{$pkg} )
			{
				unless( /::$/ )
				{
					if( defined *{ "$pkg$_" }{CODE} )
					{
						if( my $type = attributes::get( \&{ "$pkg$_" } ) )
						{
							push @$methods, "$_" if $type =~ /method/i;
						}
					}
				}
			}
		}

return $methods;
}

1;

__END__
