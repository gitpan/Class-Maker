use Test;

BEGIN { plan tests => 2 };

use Class::Maker;

use Class::Maker::Examples::Array;

ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

sub li
{
	my $title = shift;

	$title = 'Array '.$title;

	print "\n" x 3, $title, "\n", "=" x length( $title ), "\n", @_ , "\n";
}

	my $a = Array->new( array => [1..70] );

	my $b = Array->new( array => [50..100, 60] );

	li( "A", $a->totext );

	li( "B", $b->totext );

	li( "B UNIQUE", $b->unique->sort->totext );

	li( "PICK 2", $a->pick( 2 )->totext );

	li( "PICK 3", $a->pick( 3 )->totext );

	li( "UNION", $b->union( $a )->sort->totext );

	li( "DIFF", $b->diff( $a )->sort->totext );

	li( "INTERSECTION", $b->intersection( $a )->sort->totext );

	my $c = Array->new( array => [50..100] );

	my $d = Array->new( array => [50..100] );

	li( "C", $c->totext );

	li( "D", $d->totext );

	li( "C eq D", $c->eq( $d ) ? 'yes' : 'no' );

	li( "C eq A", $c->eq( $a ) ? 'yes' : 'no' );

	li( "RAND C", $c->rand->totext );

	li( "RAND and SORT C", $c->rand->sort->totext );

ok(2);
