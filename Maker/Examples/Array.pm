Class::Maker::class Array,
{
	version => '0.001',

	attribute =>
	{
		getset => [qw(max)],

		array => [qw(_array)],
	},
};

sub Array::_postinit
{
	my $this = shift;

		die 'Array needs valid _array member' unless $this->_array;
}

sub Array::push : method
{
	my $this = shift;

return push @{ $this->_array }, @_;
}

sub Array::pop : method
{
	my $this = shift;

return pop @{ $this->_array };
}

sub Array::shift : method
{
	my $this = shift;

return shift @{ $this->_array };
}

sub Array::unshift : method
{
	my $this = shift;

return unshift @{ $this->_array }, @_;
}

sub Array::count : method
{
	my $this = shift;

return scalar @{ $this->_array };
}

sub Array::clear : method
{
	my $this = shift;

return @{ $this->_array } = ();
}

sub Array::get : method
{
	my $this = shift;

return @{ $this->_array };
}

1;
