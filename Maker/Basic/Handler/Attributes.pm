package Class::Maker::Basic::Handler::Attributes;

use Carp;

use attributes ();

our $name;

our $debug_verbose = sub
{
	carp "$name: it works..." if $DEBUG;
};

	# create an attribute handler, which also accepts
	#
	# $this->member = 'syntax' instead normal $this->member( 'syntax' );

our $default = sub : lvalue
{
	my $this = shift;

@_ ? $this->{$name} = shift : $this->{$name};
};

our $array = sub
{
	my $this = shift;

		$this->{$name} = [] unless exists $this->{$name};

		@{ $this->{$name} } = () if @_;

		foreach ( @_ )
		{
			push @{ $this->{$name} }, ref($_) eq 'ARRAY' ? @{ $_ } : $_;
		}

return wantarray ? @{$this->{$name}} : $this->{$name};
};

our $hash = sub
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
};

1;
