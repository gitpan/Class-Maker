# Author: Murat Uenalan (muenalan@cpan.org)
#
# Copyright (c) 2001 Murat Uenalan. All rights reserved.
#
# Note: This program is free software; you can redistribute
#
# it and/or modify it under the same terms as Perl itself.

package Class::Maker::Extension::Schema;

	require 5.005_62; use strict; use warnings;

	use Class::Maker::Basic::Reflection 'reflect';

	use Exporter;

our $VERSION = '0.02';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(schema) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

=head1 Method B<>

=cut

my $mappings =
{
	ARRAY =>
	{
		hash => 'flat_hash',

		array => 'flat_array',
	}
};

sub _map_to_tangram
{
	my $attribs = shift;

	my $mapping = shift;

		foreach my $type ( keys %$attribs )
		{
			if( my $what = $mappings->{ ref $attribs->{$type} }->{$type} )
			{
				$attribs->{ $what } = $attribs->{ $type };

				delete $attribs->{ $type };
			}
		}

return $attribs;
}

# Preloaded methods go here.

=head1 schema( $oref )

Determines the "Tangram::Schema" representation of a "use class" including the complete inhereted objects.

Constructing Tangram Schema WHEN WE HAVE TO DEPLOY (first time registering persistance).

schema() scans recursivle through the inheritance tree and creates all parent schemas also (Cave: You should

configure tangram also via the "persistance =>" key in your class.

For comulative schema (incl. "User"`s parent "Human" class) ,+ the non-inheritated "UserGroup" Class::Maker::

	schema( 'User' , 'UserGroup' );

For single schema:

	User->schema();	#(incl. "User"`s parent "Human" class)

	or

	UserGroup->schema;	# no isa, no parent class schema`s !

=cut

our $classname_separator = '_';

sub schema
{
	my %schema = ();

	foreach my $this ( @_ )
	{
		foreach my $class ( @{Class::Maker::Basic::Constructor::inheritance_isa( ref($this) || $this )} )
		{
				# main:: and :: prefix should be stripped from package identifier
				#
				# because of a bug in bless

			$class =~ s/^(?:main)?:://;

			print "\tbase $class detected\n" if $Class::Maker::DEBUG;

				# inefficient PROVISIONAL because below i tweak in the original CLASS info, instead of doing
				# it in the schema => but NOW i have not the time...

			my %copy = %{ reflect( $class ) };

			my $reflex = \%copy;

			next if exists $reflex->{persistance}->{ignore};

			if( exists $reflex->{persistance}->{table} )
			{
				$schema{$class}->{table} = $reflex->{persistance}->{table};
			}
			elsif( 0 ) # $class =~ /::/ )	# because :: may conflict SQL
			{
				$schema{$class}->{table} = $class;

				$schema{$class}->{table} =~ s/::/$classname_separator/g;
			}

			if( exists $reflex->{persistance}->{abstract} )
			{
				$schema{$class}->{abstract} = $reflex->{persistance}->{abstract} if exists $reflex->{persistance}->{abstract};
			}
			else
			{
					# Translate fieldnames to tangram types (see above for Tangram Type Extension Modules 'use')

				foreach my $csection ( qw(attribute attr public privat) )
				{
						# look if we had a: type => [qw(eins zwei)]  ...or... type => { eins => 'Object::Eins', ...

					_map_to_tangram( $reflex->{$csection}, $mappings );
				}

				$schema{$class}->{fields} = $reflex->{attribute} if exists $reflex->{attribute};

					# look into array and ref fields for classes to be included into the schema

				foreach my $obj_field ( qw(array ref) )
				{
					if( ref( $reflex->{attribute}->{$obj_field} ) eq 'HASH' )
					{
							# cylce to the references classes and if not already in schema -> add it..

						foreach ( values %{ $reflex->{attribute}->{$obj_field} } )
						{
							unless( exists $schema{ $_ } )
							{
									# catch schema of referenced classes

								my %classes = @{ schema( $_ ) };

								foreach my $class_key ( keys %classes )
								{
									$schema{ $class_key }= $classes{$class_key};
								}
							}
						}
					}
				}

				my $isa = $reflex->{persistance}->{bases} || $reflex->{isa};

				$schema{$class}->{bases} = $isa if $isa;
			}
		}
	}

return [ %schema ];
}

1;

__END__


=head1 NAME

Class::Maker::Extension::Schema - classes, reflection, schema, serialization, attribute inheritance and multiple inheritance

=head1 SYNOPSIS

use Class::Maker qw(class);

class UnixUser,
{
	#You can use "." or "*" as a placeholder for the current package

	isa => [qw( .ParentClassA ParentClassB )],

	attribute =>
	{
		int		=> [qw(uid gid)],

		string	=> [qw(name lastname)],

		ref		=> [qw(father mother)],

		array	=> [qw(friends)],

		custom	=> [qw(anything)],
	}

	configure =>
	{
		# Future: also allow: ctor or dtor => $coderef

		ctor => 'makenew',

		explicit => 0,
	},
};

sub UnixUser::hello : method
{
	my $this = shift;

		printf 'This is %s (%d)', $this->name, $this->uid;

return 1;
}

	my $a = UnixUser->new( uid => 1, gid => 2, name => Murat );

	$a->father( UnixUser->new( name => Suleyman ) );

	$a->hello();

	$a->uid = 12;

=head1 DESCRIPTION

Class::Maker introduces the concept of classes via a "class" function. It automatically creates packages, ISA, new and attribute-handlers. The classes can inherit from common perl-classes and class-maker classes. Single and multiple inheritance is supported.

This package is for everybody who wants to program oo-perl and does not really feel comfortable with the common way.

Java-like reflection is also implemented and allows one to inspect the class properties and methods during runtime. This is  helpfull for implementing persistance and serialization. A Tangram (see cpan) schema generator is included to the package, so one can use Tangram object-persistance on the fly as long as he uses Class::Maker classes.

=head1 INTRODUCTION

When you want to program oo-perl, mostly you suffer under the flexibility of perl. It is so flexibel, you have to do alot by hand. Here an example (slightly modified) from perltoot perl documentation for demonstration:

package Person;

@ISA = qw(Something);

sub new {
    my $self  = {};
    $self->{NAME}   = undef;
    $self->{AGE}    = undef;
    bless($self);           # but see below
    return $self;
}

sub name {
    my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}

sub age {
    my $self = shift;
    if (@_) { $self->{AGE} = shift }
    return $self->{AGE};
}

After using cpan modules for some time, i felt still very uncomfortable because i am used to c++ which has really straightforward class decleration style. It looks really beautiful. I love good looking syntax. So i have written a "class" function which <easily> creates perl classes. And i want it to be smoothly integrated into perl code with comprehensive handling of package issues etc:

use Class::Maker qw(class);

class Person,
{
	isa => [ Something ],

	attributes =>
	{
		scalar => [qw( name age )],
	},
};

When using "class", you do not explictly need "package". The function does all symbol creation for you. It is more a class decleration (like in java/cpp/..):

=cut
