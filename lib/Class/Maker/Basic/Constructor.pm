
# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself
#
# Author:	Murat Uenalan (muenalan@cpan.org)
#
# Copyright:	Copyright (c) 1997 Murat Uenalan. All rights reserved.
#
# Note:		This program is free software; you can redistribute it and/or modify it
#
#		under the same terms as Perl itself.

package Class::Maker::Basic::Constructor;

	require 5.005_62; use strict; use warnings;

use Exporter;

our $VERSION = '0.02';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(new) ],	'std' => [ qw(new) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

# Preloaded methods go here.

our @init_methods = qw( init initialize );

sub simple_new
{
	my $this = shift;

	bless {}, ref( $this ) || $this;
}

=pod

	"overriden attribute-names" are not dramatic, because every attribute
	gets its classname prepended like "Object::attribute" into the hash
	representation of the object.

	But you must be aware that when initializing via new( public => ),
	alwas the first parent attribute is used for the initalization.

	new( Parent1::field => 'bla', Parent2::field => 'blabla' );

=cut

	# multiple inheritance constructor (shouldn't be overriden, otherwise no MI)

sub new
{
	my $what = shift;

		my $class = ref( $what ) || $what;

			# convert constructor arguments to accessor/method calls

		my @args = @_;
		
		my %args;
		
		if( $class->can( '_arginit' ) )
		{
			$class->_arginit( \@args );
		}

	use Data::Dump qw(pp);

	if( scalar @args % 2 != 0 )
	{
	        warn "*INVALID HASH*, Odd number of args, dump =", pp @args;
	}

		%args = @args;
		
		my $args = \%args;

		_filter_argnames( $args );

			# look if we just need cloning

		if( ref( $what ) )
		{
			my %copy = %$what;

			my $clone = bless \%copy, $class;

			while( my ( $key, $value ) = each %args )
			{
				$clone->$key( $value );
			}

			return $clone;
		}

			# if we do not clone, construct a new instance

		my $this = bless {}, $class;

			# preset all defaults

		my $rfx = Class::Maker::Reflection::reflect( $class ) or die;

		if( $rfx->definition )
		{
			_defaults( $this, $rfx->definition->{default} ) if exists $rfx->definition->{default};
		}

			# inheriting attributes here

		warn( sprintf "NEW TRAVERSING ISA: %s", join( ', ', @{ Class::Maker::Reflection::inheritance_isa( ref( $this ) ) } ) ) if $Class::Maker::DEBUG;

		foreach my $parent ( @{ Class::Maker::Reflection::inheritance_isa( ref( $this ) || die ) } )
		{
			my $class = ref($this);

			bless $this, $parent;

			no strict 'refs';

			"${parent}::_preinit"->( $this, $args ) if defined *{ "${parent}::_preinit" }{CODE};

			foreach my $init_method ( @init_methods )
			{
				if( defined *{ "${parent}::${init_method}" }{CODE} )
				{
					"${parent}::${init_method}"->( $this, $args );

					last;
				}
			}

			foreach my $attr ( keys %{$args} )
			{
				if( defined *{ "${parent}::${attr}" }{CODE} )
				{
					"${parent}::${attr}"->( $this, $args->{$attr} );

					delete $args->{$attr};
				}
			}

			"${parent}::_postinit"->( $this, $args ) if defined *{ "${parent}::_postinit" }{CODE};

			bless $this, $class;
		}

		# call constructor arguments as functions, because we assume attribute-handlers

		warn "Unhandled new() arg: '$_' (Implement attribute-handler or check spelling)" for keys %args;

return $this;
}

# functions

sub _filter_argnames
{
	my $temp = shift;

			# rename all -arg or --arg fields

		foreach my $key ( keys %$temp )
		{
			if( $key =~ /^\-+(.*)/ )
			{
				$temp->{$1} = $temp->{$key};

				delete $temp->{$key};
			}
		}
}

sub _defaults
{
	my $this = shift;

	my $args = shift;

	no strict 'refs';

	foreach my $attr ( keys %$args )
	{
		if( my $coderef = $this->can( $attr ) )
		{
			print "Setting $this default (via coderef $coderef) $attr = ", $args->{$attr}, "\n" if $Class::Maker::DEBUG;

			$coderef->( $this, $args->{$attr} );

			#$this->$attr( $args->{$attr} );
			#$this->{$attr} = $args->{$attr};
		}
	}
}

1;

__END__

	# cookbook says in Recipe 13.10
	# my $self = bless {}, $class;
	#
	# for my $class (@ISA) {
	#     my $meth = $class . "::_init";
	#     $self->$meth(@_) if $class->can("_init");
	# }

	# This calls a parent method with our object/package.
	# "This is very fragile code" as stated in the cookbook
	# recipe 13.10, which breaks into unusability when we
	# have following scenario:
	#
	# The "_init" method of the parent class contains method calls
	# of his own class and this method is overriden in this class.
	#
	# What happens is that within the init method of the foreign
	# class the overriden method of the child class is called which
	# in most cases leads to wrong initialization of our object.
	#
	# Further: The main problem is that we call a parent method
	# with an object blessed in our current package !
	#
	# SOLUTION: Correctly create a parent object (which leads to
	# the right blessing and therefore for correct package/object
	# scenario) and simply copy the attributes of the parent
	# to the child.

	# store old package/class name


=head1 NAME

Class::Maker - classes, reflection, schemas, serialization, attribute- and multiple inheritance

=head1 SYNOPSIS

  use Class::Maker qw(:all);

  class Something;

  class Person,
  {
     isa => [ 'Something' ],

     public =>
     {
       scalar => [qw( name age internal )],
     },

     private
     {
       int => [qw( internal )],
     },
  };

  sub Person::hello
  {
    my $this = shift;

    $this->_internal( 2123 ); # the private one

    printf "Here is %s and i am %d years old.\n",  $this->name, $this->age;
  };

  my $p = Person->new( name => Murat, age => 27 );

  $p->hello;


=head1 DESCRIPTION

This package descibes the default constructor functionality. It is central to L<Class::Maker> because during its call reflection, initialization, inheritance gets handled.

=head2 SPECIAL METHODS

=head3 sub _arginit : method

Once this method exists in the package of the class it is called right after L<new()> was dispatched. It is generally for the modification of the C<@_> arguments to a convinient way C<new()> can handle it (It always expects a hash, but with this function one could translate an array to the hash).

=head3 sub _preinit : method

=head3 sub _postinit : method


=head1 CONTACT

Sourceforge L<http://sf.net/projects/datatype> is hosting a project dedicated to this module. And I enjoy receiving your comments/suggestion/reports also via L<http://rt.cpan.org> or L<http://testers.cpan.org>. 

=head1 AUTHOR

Murat Uenalan, <muenalan@cpan.org>

