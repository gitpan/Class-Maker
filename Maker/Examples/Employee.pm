our $VERSION = '0.001';

use Class::Maker::Examples::Human;

#use Object::Debugable;

package  Employee;

Class::Maker::class
{
	version => $VERSION,

	isa => [qw( Human )],

	#has => { Person => [qw(father mother sister brother)],

	public =>
	{
		getset => [qw( firstname income payment position )],
	},

	private =>
	{
		int => [qw( dummy1 dummy2 )],
	},

	configure =>
	{
		ctor => 'new',

		dtor => 'delete',

		explicit => 1,

		private => { prefix => '__' },
	},
};

sub _preinit
{
	my $this = shift;

		#whereami();
}

sub _postinit
{
	my $this = shift;

		#whereami();
}

=head1 Method B<>

=cut

sub phantom : method
{
	my $this = shift;

return;
}

1;
