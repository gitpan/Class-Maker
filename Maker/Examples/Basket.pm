our $VERSION = '0.001';

use Class::Maker::Examples::Array;

#use Set::Bag;

Class::Maker::class Basket,
{
	version => $VERSION,

	isa => [qw(Array)], # Set::Bag)],

	attribute =>
	{
		getset => [qw( owner maximum )],
	},
};

1;
