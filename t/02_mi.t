BEGIN
{
	$| = 1; print "1..1\n";
}

my $loaded;

use strict;

use Carp;

#use Object::Debugable qw(debugDump debugSymbols);

use Class::Maker qw(class);

	eval
	{
		1;
	};
	if($@)
	{
		croak "Exception caught: $@\n";

		print 'not ';
	}

printf "ok %d\n", ++$loaded;

