our $VERSION = '0.001';

use Class::Maker::Examples::User;

Class::Maker::class Customer,
{
	version => $VERSION,

	isa => [qw( User )],

	attribute =>
	{
		getset => [qw( firstname income payment position )],
	},

	configure =>
	{
		ctor => 'new', dtor => 'delete',
	},
};

sub Customer::_preinit
{
	my $this = shift;
}

sub Customer::_postinit
{
	my $this = shift;
}

1;
