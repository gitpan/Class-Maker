our $VERSION = '0.001';

use Class::Maker::Examples::Human;

{
	package Vehicle;

	Class::Maker::class
	{
		attribute =>
		{
			int => [qw( wheels )],

			string => [qw( model )],
		},
	};
}

package User;

Class::Maker::class
{
	version => '0.01',

	isa => [qw( Human )],

	public =>
	{
		int => [qw( logins )],

		real => [qw( konto )],

		string => [qw( email lastlog registered )],

		ref => { group => 'User::Group' },

		array => { friends => 'User', cars => 'Vehicle' },
	},
};

sub _preinit
{
	my $this = shift;

			@$this{qw( lastlog registered )} = qw(NULL NULL);
}

package User::Group;

Class::Maker::class
{
	attribute =>
	{
		string => [qw( name descr )],
	},
};

1;
