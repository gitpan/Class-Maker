our $VERSION = '0.001';

use Class::Maker::Examples::Human;

#use Object::Debugable;

Class::Maker::class Employee,
{
	version => $VERSION,

	isa => [qw( Human )],

	#has => { Person => [qw(father mother sister brother)],

	attribute =>
	{
		getset => [qw( firstname income payment position )],
	},

	configure =>
	{
		ctor => 'new',

		dtor => 'delete',

		explicit => 1,
	},
};

sub Employee::_preinit
{
	my $this = shift;

		#whereami();
}

sub Employee::_postinit
{
	my $this = shift;

		#whereami();
}

=head1 Method B<>

=cut

sub Employee::phatom : method
{
	my $this = shift;


return;
}

1;
