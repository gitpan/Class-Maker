package Class::Maker::Basic::Handler::Attributes;

use Class::Maker::Basic::Constructor; #qw(defaults);

use Carp;

our $DEBUG = 0;

our $name;

sub new
{
	return \&Class::Maker::Basic::Constructor::new;
}

sub simple_new
{
	return \&Class::Maker::Basic::Constructor::simple_new;
}

sub debug_verbose
{
	my $name = $name;

	return sub
	{
		warn "$name: it works..." if $DEBUG;
	}
}

	# create an "lvalue" attribute handler, which also accepts
	#
	# $this->member = 'syntax' instead normal $this->member( 'syntax' );

{ 
	package Class::Maker::Basic::Handler::Attributes::default;

	sub get : method
	{
		my $this = shift;

		my $name = shift;
		
	return $this->{$name};
	}

	sub set : method
	{
		my $this = shift;

		my $name = shift;
		
	return $this->{$name} = shift;
	}

		# when setting the value via the constructor
		
	sub init : method
	{	
	}
	
	sub reset : method
	{
		# do reset to default value from instantiation
	}
}

sub default
{
	my $name = $name;

	return sub : lvalue
	{
		my $this = shift;

		my $name = $name;
	
			if( @_ )
			{
				Class::Maker::Basic::Handler::Attributes::default::set( $this, $name, shift );
			}
			else
			{ 
				Class::Maker::Basic::Handler::Attributes::default::get( $this, $name );
			}
		
		$this->{$name};
	};
}

{ 
	package Class::Maker::Basic::Handler::Attributes::array;

	use Carp;
	
	sub get : method
	{
		my $this = shift;

		my $name = shift;
		
	return $this->{$name};
	}

	sub set : method
	{
		my $this = shift;

		my $name = shift;
		
			croak "Array reference expected" unless ref( $_[0] ) eq 'ARRAY';
			
	return @{ $this->{$name} } = @{ $_[0] };
	}

		# when setting the value via the constructor
		
	sub init : method
	{	
		my $this = shift;

		my $name = shift;
		
	return $this->{$name} = shift;
	}

	sub reset : method
	{
		# do reset to default value from instantiation
	}
}

sub array
{
	my $name = $name;

	return sub
	{
		my $this = shift;

		my $name = $name;

			Class::Maker::Basic::Handler::Attributes::array::init( $this, $name, [] ) unless exists $this->{$name};

			Class::Maker::Basic::Handler::Attributes::array::set( $this, $name, @_ ) if @_;
			
			if( wantarray )
			{
				return @{ Class::Maker::Basic::Handler::Attributes::array::get( $this, $name ) };
			}
	
	return Class::Maker::Basic::Handler::Attributes::array::get( $this, $name );
	}
}

{ 
	package Class::Maker::Basic::Handler::Attributes::hash;
	
	use Carp;
	
	sub get : method
	{
		my $this = shift;

		my $name = shift;
		
	return $this->{$name};
	}

	sub set : method
	{
		my $this = shift;

		my $name = shift;
		
			croak "Hash reference expected" unless ref( $_[0] ) eq 'HASH';
			
	return %{ $this->{$name} } = %{ $_[0] };
	}

		# when setting the value via the constructor
		
	sub init : method
	{	
		my $this = shift;

		my $name = shift;
		
	return $this->{$name} = shift ;
	}

	sub reset : method
	{
		# do reset to default value from instantiation
	}
}

sub hash
{
	my $name = $name;

	return sub
	{
		my $this = shift;

		my $name = $name;

			Class::Maker::Basic::Handler::Attributes::hash::init( $this, $name, {} ) unless exists $this->{$name};
			
			Class::Maker::Basic::Handler::Attributes::hash::set( $this, $name, @_ ) if @_;
			
			if( wantarray )
			{
				return %{ Class::Maker::Basic::Handler::Attributes::hash::get( $this, $name ) };
			}
	
	return Class::Maker::Basic::Handler::Attributes::hash::get( $this, $name );
	}
}

1;
