package Array;

Class::Maker::class
{
	attribute =>
	{
		getset => [qw(max)],

		array => [qw(_array)],
	},
};

sub Array::push : method
{
	my $this = shift;

return push @{ $this->_array }, @_;
}

sub Array::pop : method
{
	pop @{ shift->_array };
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
	scalar @{ shift->_array };
}

sub Array::clear : method
{
	@{ shift->_array } = ();
}

sub Array::get : method
{
	@{ shift->_array };
}

1;
