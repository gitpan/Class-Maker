# Author: Murat Uenalan (muenalan@cpan.org)
#
# Copyright (c) 2001 Murat Uenalan. All rights reserved.
#
# Note: This program is free software; you can redistribute
#
# it and/or modify it under the same terms as Perl itself.

package Class::Maker;

our $VERSION = '0.05_01';

require 5.005_62; use strict; use warnings;

use attributes ();

use Carp;

use Class::Maker::Basic::Constructor;

use Class::Maker::Basic::Handler::Attributes;

use Class::Maker::Basic::Fields;

use Class::Maker::Basic::Reflection qw(reflect classes);

use Exporter;

use subs qw(class);

our $DEBUG = 0;

our $TRACE = ( \*STDOUT, \*STDERR )[ ($ENV{CLASSMAKER_TRACE}||2) - 1 ];

our %EXPORT_TAGS = ( 'all' => [ qw(class reflect classes) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(class);

our @ISA = qw( Exporter );

our $pkg = '<undefined class>';

our $cpkg = $pkg;

our $explicit = 0;

# Preloaded methods go here.

sub import
{
	Class::Maker->export_to_level( 1, @_ );
}

sub class
{
	class_import( scalar caller, @_ );
}

sub class_import
{
		# $class is the caller package

	my ( $class, @args ) = @_;

	return unless @args;

		# construct the destination package for the classes:
		#
		#	- we create the class within the current package (default)
		#	- or create it in the current package
		#	- or when starting with 'main::' or '::' we create it with the main package

	unless( ref $args[0]  )
	{
		$pkg = ( $args[0] =~ s/^(?:main)?::// ) ? $args[0] : $class.'::'.$args[0];
	}
	else
	{
			# We had no explicit destination package, so create the class in the current package

		$pkg = $class;
	}

		#remember caller package

	$cpkg = $class;

	carp "Package: $pkg (caller $class)" if $DEBUG;

		# init class 'cause somebody could give an empty parameter
		# list for abstract classes

	Class::Maker::Basic::Fields::isa( [] );

	Class::Maker::Basic::Fields::configure( { ctor => 'new', dtor => 'delete' } );

	foreach my $arg ( @args )
	{
		carp "Import: $arg" if $DEBUG;

		if( ref($arg) eq 'HASH' )
		{
			no strict 'refs';

				# class reflection

			${ Class::Maker::findclass( $pkg ) } = $arg;

			foreach my $func ( sort { $b cmp $a } keys %$arg )
			{
					# "classfields" for the class attributes/isa/configure/..

				"Class::Maker::Basic::Fields::${func}"->( $arg->{$func}, $arg );
			}
		}
	}
}

sub _get_code
{
	my $type = shift;

	my $name = shift;

	$name = "${pkg}::$name" if $explicit;

	my $code =
	{
		new => \&Class::Maker::Basic::Constructor::new,

		simple_new => \&Class::Maker::Basic::Constructor::simple_new,

		debug_verbose => sub
		{
			carp "'$name' works..." if $DEBUG;
		},

		default => sub : lvalue
		{
			my $this = shift;

		@_ ? $this->{$name} = shift : $this->{$name};
		},

		array => sub
		{
			my $this = shift;

				$this->{$name} = [] unless exists $this->{$name};

				@{ $this->{$name} } = () if @_;

				foreach ( @_ )
				{
					push @{ $this->{$name} }, ref($_) eq 'ARRAY' ? @{ $_ } : $_;
				}

		return wantarray ? @{$this->{$name}} : $this->{$name};
		},

		hash => sub
		{
				my $this = shift;

				unless( exists $this->{$name} )
				{
					$this->{$name} = {};
				}

				foreach my $href ( @_ )
				{
					if( ref($href) eq 'HASH' )
					{
						foreach my $key ( keys %{ $href } )
						{
							$this->{$name}->{$key} = $href->{$key};
						}
					}
				}

		return wantarray ? %{ $this->{$name} } : $this->{$name};
		},
	};

return $code->{lc $type} || $code->{'default'};
}

sub _make_method
{
	no strict 'refs';

	my $method_type = shift;

	my $name = shift;

	my $prefix = shift || '';

		$name = $prefix . $name;

		my $varname = "${pkg}::$name";

		carp "func: $varname\n" if $DEBUG;

		*{ $varname } = _get_code( $method_type, $name ) unless defined *{ $varname }{CODE};
}

sub findclass
{
	my $class = shift;

		no warnings;

		no strict 'refs';

return \${ "${class}::CLASS" };
}

1;
__END__

=head1 NAME

Class::Maker - classes, reflection, schema, serialization, attribute- and multiple inheritance

=head1 SYNOPSIS

use Class::Maker qw(class);

class Human,
{
	isa => [qw( ParentClass )],

	public =>
	{
		string	=> [qw(name lastname)],

		ref		=> [qw(father mother)],

		array	=> [qw(friends)],

		custom	=> [qw(anything)],
	},

	private =>
	{
		int     => [qw(dummy1 dummy2)],
	},

	configure =>
	{
		ctor => 'create',

		explicit => 0,
	},
};

sub Human::greeting : method
{
	my $this = shift;

		printf 'This is %s (%d)', $this->name, $this->uid;
}

class UnixUser,
{
	isa => [qw( Human )],

	public =>
	{
		int		=> [qw(uid gid)],

		string	=> [qw(username)],
	},
};

	my $a = Human->new( uid => 1, gid => 2, name => Bart );

	$a->father( Human->new( name => Houmer ) );

	$a->greeting();

	$a->uid = 12;

	$a->_dummy1( 'bla' );

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

=head1 CLASS FUNCTION

The 'class' function is very central to Class::Maker. It may be called with or without braces.

	Syntax:		class 'NAME' is optional , {DESCRIPTORS};

	The parantheses for the class() function are optional.

	'NAME' is the Name for the class. It is also the name for the package where the symbols for the class are created.

		Examples:	'Animal', 'Animal::Spider', 'Histology::Structures::Epithelia'

		Normally the class is created related to the main package:

			Example:
					package Far::Far::Away;

					class 'Galaxy',
					{
					};

		'Galaxy' would become to 'main::Galaxy'.

		Feature: If you want it below the current package, just add a '.' or '*' in front of the class name:

			Example:
					package Far::Far::Away;

					class '.Galaxy',
					{
					};

		'.Galaxy' would become 'Far::Far::Away::Galaxy'.

	{DESCRIPTORS}

	is a hashref. The entries are called FIELDS and are described below.

=head1 FIELDS

Fields are the keys in the hashref given as the second (or first if the first argument (classname) is omitted) argument to "class". Here are the basic fields (for adding new fields read the Class::Maker::Basic::Fields).

=over 4

=item isa

	Arguments: arrayref

	Same as the @ISA array in an package (see perltoot). Additionally following special features are added:

		a) when the name is started with an '.' or '*' the package name is extrapolated to that name:

			Example:
					package Far::Far::Away;

					class Galaxy,
					{
						isa => [qw( .AnotherGalaxy )],
					};

			'.AnotherGalaxy' becomes expanded to 'Far::Far::Away::AnotherGalaxy'.

=item The attribute group (attr|attributes|private|public)

	Arguments: hashref

	This keys are 'type-identifiers' (no fear, its simple), which help you to sort things.

	In general these are used to create handlers for the type. It is somehow like the get/set
	like method functions to access class-properties, but its more generalized and not so
	restrictive.

	By default, every non-known type-identifier is a simple scalar handler. Class::Maker will
	not warn you at any point, if you use a unknown type-identifier.

		Example:

			int => [qw(id)],

		leads to a attribute-handler which can be used like:

			$obj->id( 123 );

			my $value = $obj->id;

		Because the default handler is an lvalue function, the following call is also valid:

			$obj->id = 5678;

=item private

	All properties in the 'private' section, get a '_' prepended to their names.

	private =>
	{
		int		=> [qw(uid gid)],
	},

	So you must access 'uid' with $obj->_uid();

=item public|attribute|attr

	public =>
	{
		int		=> [qw(uid gid)],

		string	=> [qw(name lastname)],

		ref		=> [qw(father mother)],

		array	=> [qw(friends)],

		custom	=> [qw(anything)],
	}

=item configure

	This Field is for general options. Basicly following options are supported:

		a) new: The name of the default constructor is 'new'. With this option you can change the
		name to something of your choice. For instance:

			new => 'connect'

			could be used for database objects. So you would use

			my $obj AnyClass->connect( );

			to create an AnyClass object.

		b) explicit: Internally an instance of a class hold all properties/attributes in an hash
		(The object is blessed with a hash-ref). The keys are normally exactly the same as you
		declare in the descriptors. But when you do inheritance, you may have name clashes if a
		parent object uses the same name for property. To compensate that problem, set explicit
		to something true (i.e. 1). This will lead to internal prepending of the classname to the
		key name:

		Example:

		'A' inherits 'B'. Both have a 'name' property. With explicit internally the fields
		are distinct:

			A::name
			B::name

		CAVEAT: This does not collide with attribute-overloading/inheritance ! Because the first
		attribute-handler in the isa-tree is always called. You do not have to care for this.

		Only use this feature, if you have fear that name clashes could appear, beside overloading. Per default
		it is turned off, because i suppose that most class designers care for name clashes themselfs.

		c) I<private>

			- prefix string (default '_') for private functions can be changed with this.

		Example:

			private =>
			{
				int => [qw(dummy1)],
			},
			configure =>
			{
				private => { prefix => '__' },
			},

		would force to access 'dummy1' via ->__dummy1().

=item automethod

	Reserved.

=item has

	Reserved. Is planned to be used for 'has a' relationships.

=item default

	Reserved. In future here you can give default values for class attributes.

=item version

	Give the class/objects a version number. Internally the $VERSION is set to that value.

=item can

	Here you can manually list all class methods. So under reflection you can inspect this field.
	This obsolete and is not recommended, because there is a better mechinism implemented.
	If you declare a function use the ': method' identifier/attribute.

	Example:

	sub AnyClass::calc : method
	{
		my $this = shift;

	}

	This is important, because when the class is reflected all subs which have the attribute ': method'
	are handled as 'methods', all others are 'functions'.

=item persistance

	Here you can set options and add information for the reflect-function. You can also add custom information,
	you may want to process when you reflect objects.

	Example:

		For example the tangram-schema generator looks for an 'abstract' key, to handle this class as an abstract
		class:

		persistance =>
		{
			abstract => 1,
		},

		You can read more about Persistance under the Class::Maker::Extension::Persistance manpage.

=back

=back

=head1 INTERNALS

Following happens in the background, when using 'class':

=over 4

=item creates a package "Person".
=item sets @Person::ISA to the [ 'Something' ].
=item creates method handlers for the attributes (including lvalue methods).
=over 4
while only "hash" and "array" keys are keywords, any other
will result in a simple get/set method (this is very usefull for pseudo types, wich can be later
implemented).

=back

=item exports a default constructor "Person::new()"
=item which handles argument initialization
=item has a mechanism for initializing the parent objects (including MI)
=item so you don't need to do it yourself
=item creates $Person::CLASS holding a hashref to the structure [the second argument]
=item good for reflection: i.e. you can get runtime information about the class
=over 4
=item usable for dependency/class walking
=item creating on-the-fly persistance => in combination with Tangram (through reflection)
=item it creates the complete tangram schema tree (Tangram users know how hard it is
=item to have x hand-maintained schema-hashes => here you get everything automatic).
=back

=back

=head2 PERFORMANCE

I never benchmarked Class::Maker. Because the internal representation is just the same as for
standard perl-classes, only a minimal delay in the constructor (during scan through the class hirarchy for _init() routines) is apparent.

=head2 EXAMPLES

=head1 HOW TO WRITE A MODULE WITH Class::Maker

See the Class::Maker::Examples manpage for examples how to write basic data-type-like classes and basic classes
used for i.e. e-commerce applications.

=head2 EXPORT

facultativ: qw(reflect schema)
obligat:	qw(class)

class by default.

=head1 AUTHOR

Author: Murat Uenalan (muenalan@cpan.org)

Contributions (Ideas or Code):

	- Terrence Brannon

=head1 COPYRIGHT

(c) 2001 by Murat Uenalan. All rights reserved.
Note: This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), perlboot, perltoot, perltootc

=head1 Search for Class::Maker::* at CPAN

Also at CPAN: Class::*, Tangram

=head1 LITERATURE

[1] Object-oriented Perl, Damian Conway
[2] Perl Cookbook, Nathan Torkington et al.

=cut
