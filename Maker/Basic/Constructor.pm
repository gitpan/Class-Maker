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

	#use Bugfix::ref qw(ref bless);

	use Carp;

	use IO::Extended ':all';

	use Exporter;

our $VERSION = '0.01';

our $DEBUG = 0;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(new defaults) ],	'std' => [ qw(new) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

# Preloaded methods go here.

sub simple_new
{
	my $this = shift;

	bless {}, ref( $this ) || $this;
}

=pod

	"overriden attribute-names" are not dramatic, because every attribute
	gets its classname prepended like "Object::attribute" into the hash
	representation of the object.

	But you must be aware that when initializing via new( attribute => ),
	alwas the first parent attribute is used for the initalization.

	new( Parent1::field => 'bla', Parent2::field => 'blabla' );

=cut

	# multiple inheritance constructor

sub new
{
	my $class = shift;

		$class = ref( $class ) || $class;

		my $this = bless {}, $class;

		my %temp = @_;

		foreach my $key ( keys %temp )
		{
			if( $key =~ /^\-+(.*)/ )
			{
				$temp{$1} = $temp{$key};

				delete $temp{$key};
			}
		}

		my $args = \%temp;

		# inheriting attributes here

		::carp( sprintf "NEW TRAVERSING ISA: %s", join( ', ', @{ inheritance_isa( ref( $this ) ) } ) ) if $DEBUG;

		foreach my $parent ( @{ inheritance_isa( ref( $this ) || die ) } )
		{
			my $class = ref($this);

			bless $this, $parent;

			no strict 'refs';

			if( defined *{ "${parent}::_preinit" }{CODE} )
			{
				"${parent}::_preinit"->( $this, $args );
			}

			foreach my $initmethod ( qw( init initialize ) )
			{
				if( defined *{ "${parent}::${initmethod}" }{CODE} )
				{
					"${parent}::${initmethod}"->( $this, $args );

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

			if( defined *{ "${parent}::_postinit" }{CODE} )
			{
				"${parent}::_postinit"->( $this, $args );
			}

			bless $this, $class;
		}

		# call constructor arguments as functions, because we assume attribute-handlers

		foreach ( keys %temp )
		{
			warn "Unhandled ctor arg: '$_' (Implement attribute-handler or check spelling)";
		}

return $this;
}

# functions

sub defaults
{
	my $this = shift;

	my %args = @_;

	foreach my $attr ( keys %args )
	{
		if( my $coderef = $this->can( $attr ) )
		{
			$this->$coderef( $args{$attr} );
		}
	}
}

sub classISA
{
	no strict 'refs';

return @{ $_[0].'::ISA'};
}

sub _isa_tree
{
	my $list = shift;

	my $level = shift;

	for my $child ( @_ )
	{
		my @parents = classISA( $child );

		$level++;

		push @{ $list->{$level} }, $child;

		::carp sprintf "\@%s::ISA = qw(%s);",$child , join( ' ', @parents ) if $DEBUG;

		_isa_tree( $list, $level, @parents );

		$level--;
	}
}

	# returns the isa tree sorted by level of recursion

	# 5 -> Exporter
	# 4 -> Object::Debugable
	# 3 -> Person, Exporter
	# 2 -> Employee, Exporter, Object::Debugable
	# 1 -> Doctor

sub isa_tree
{
	my $list = {};

	_isa_tree( $list, 0, @_ );

return $list;
}

	# returns the isa tree in a planar list (for con-/destructor queue's)

sub inheritance_isa
{
	::carp sprintf "SCANNING ISA FOR (%s);", join( ', ', @_ ) if $DEBUG;

	my $construct_list = isa_tree( @_ );

	my @ALL;

	foreach my $level ( sort { $b <=> $a } keys %$construct_list )
	{
		push @ALL, @{ $construct_list->{$level} };
	}

return \@ALL;
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
