our $VERSION = '0.002';

package Human;

Class::Maker::class
{
	version => $VERSION,

	attribute =>
	{
		int => [qw(age)],

		string =>
		[
			qw(coutrycode postalcode firstname lastname sex eye_color),

			qw(hair_color occupation city region street telefon fax)
		],

			# look how driverslicense has the <> syntax and therefore becomes
			# private (_driverslicense)

		time => [qw(birth <driverslicense> dead)],

		array => [qw(nicknames friends)],

		hash => [qw(contacts telefon)],

		whatsit => { '<tricky>' => 'An::Object' },
	},

	configure =>
	{
		# Future: also allow: ctor => $coderef

		ctor => 'new',

		dtor => 'delete',

		explicit => 0,
	},
};

sub _preinit
{
	my $this = shift;

		@$this{ qw(firstname lastname sex) } = qw( john doe male );

		@$this{ qw(birthday) } = qw(NULL);
}

sub _postinit
{
	my $this = shift;

		#::printfln "Human born as %s %s today !!\n", $this->firstname, $this->lastname;
}

1;
