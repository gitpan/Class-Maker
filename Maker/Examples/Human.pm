our $VERSION = '0.001';

Class::Maker::class Human,
{
	version => $VERSION,

	attribute =>
	{
		int => [qw(age)],

		string => [qw(coutrycode postalcode firstname lastname sex eye_color hair_color occupation city region street telefon fax)],

		#rawdatetime => [qw(birthday)],

		array => [qw(nicknames friends)],

		hash => [qw(contacts telefon)],
	},

	configure =>
	{
		# Future: also allow: ctor => $coderef

		ctor => 'new',

		dtor => 'delete',

		explicit => 0,
	},
};

sub Human::_preinit
{
	my $this = shift;

		@$this{ qw(firstname lastname sex) } = qw( john doe male );

		@$this{ qw(birthday) } = qw(NULL);
}

sub Human::_postinit
{
	my $this = shift;

		#::printfln "Human born as %s %s today !!\n", $this->firstname, $this->lastname;
}

1;
