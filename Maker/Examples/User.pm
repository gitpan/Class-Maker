our $VERSION = '0.001';

use Class::Maker::Examples::Human;

Class::Maker::class 'Vehicle',
{
	attribute =>
	{
		int => [qw( wheels )],

		string => [qw( model )],
	},
};

Class::Maker::class 'User',
{
	version => '0.01',

	isa => [qw( Human )],

	attribute =>
	{
		int => [qw( logins )],

		real => [qw( konto )],

		string => [qw( email lastlog registered )],

		ref => { group => 'User::Group' },

		array => { friends => 'User', cars => 'Vehicle' },
	},
};

sub User::_preinit
{
	my $this = shift;

			@$this{qw( lastlog registered )} = qw(NULL NULL);
}

Class::Maker::class 'User::Group',
{
	attribute =>
	{
		string => [qw( name descr )],
	},
};

1;
