BEGIN
{
	$| = 1;

	if( exists $ENV{MOD_NOTEST} )
	{
		die "DEBUG MODE OFF";
	}

	print "1..1\n";
}

use strict;

use Data::Dumper;

use IO::Extended qw(:all);

use Class::Maker;

use Class::Maker::Examples::User;

use Class::Maker::Examples::Customer;

use Class::Maker::Examples::Employee;

use Class::Maker::Examples::Shop;

	println "\nFinishing class definition.\n\n\nStarting testing\n";

	ind 1;

	println;

	println "Instantiate Human...";

		# Object Human

	my $human = new Human(

		firstname => 'Adam',

		lastname => 'NoName',

		eye_color => 'green',

		hair_color => 'black',

		nicknames => [qw( TheDuke JohnDoe )],

		contacts => { Peter => 'peter@anywhere.de' },

		telefon => { Phone => '01230230', Fax => '0237923487' },
	);

	push @{ $human->nicknames }, qw( Maniac TwistedBrain );

	$human->telefon->{Mobil} = '0123823727';

	foreach my $key ( keys %{ $human->telefon } )
	{
		::ind 1;

		::printfln "Telefon: %20s (%s)\n", $key, $human->telefon->{$key};
	}

	$human->firstname = 'Adam!';

	println "Instantiate Employee...";

		# Object Employee

	my $employee = new Employee(

		firstname => 'Fred',

		lastname => 'Firestone',

		eye_color => 'brown',

		hair_color => 'black',

		income => '100 rockdollar/year',

		payment => 'monthly',

		position => 'assistant',

		friends => [qw( Peter Lora John )],
	);

	$employee->eye_color = 'something like '.$employee->eye_color;

	$employee->Employee::firstname( 'employee_name' );

	#debugSymbols( 'main::Human::' );

	foreach my $class ( qw( Human Employee Customer User ) )
	{
		print "\n$class methods: ", join( ', ', @{ reflect( $class, 'methods' ) } ), "\n" if reflect( $class, 'methods' );
	}

	println "human eyecolor: ", $human->hair_color;

	foreach my $class ( qw( Human Employee Customer User ) )
	{
		print Dumper reflect( $class );
	}

	$Class::Maker::Basic::Constructor::DEBUG = 1;

	printfln "TRAVERSING ISA: %s", join( ', ', @{ Class::Maker::Basic::Constructor::inheritance_isa( 'Employee' ) } );

	our $loaded = 1;

	print "ok 1\n";

END { print "not ok 1\n" unless $loaded; }
