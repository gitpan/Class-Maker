package Array;

Class::Maker::class
{
	attribute =>
	{
		getset => [qw( max )],

		array => [qw( _array )],
	},
};

sub push : method
{
	my $this = shift;

return push @{ $this->_array }, @_;
}

sub pop : method
{
	pop @{ shift->_array };
}

sub shift : method
{
	my $this = shift;

return shift @{ $this->_array };
}

sub unshift : method
{
	my $this = shift;

return unshift @{ $this->_array }, @_;
}

sub count : method
{
	scalar @{ shift->_array };
}

sub clear : method
{
	@{ shift->_array } = ();
}

sub get : method
{
	@{ shift->_array };
}

sub union : method
{
	my $this = shift;

		my $other = shift;

return @{ _calc( $this->_array, $other ) }[0];
}

sub intersection : method
{
	my $this = shift;

		my $other = shift;

return @{ _calc( $this->_array, $other ) }[1];
}

sub difference : method
{
	my $this = shift;

		my $other = shift;

return @{ _calc( $this->_array, $other ) }[2];
}

sub _calc
{
	my ( $a, $b ) = @_;

	die 'argument type mismatch for _calc( aref, aref )' unless ref($a) eq 'ARRAY' && ref($a) eq 'ARRAY';

	my @array1 = @$a;

	my @array2 = @$b;

	no strict;

	@union = @intersection = @difference = ();

	%count = ();

	foreach $element (@array1, @array2) { $count{$element}++ }

	foreach $element (keys %count)
	{
	    push @union, $element;

	    push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element;
	}

return ( \@union, \@intersection, \@difference );
}

1;
