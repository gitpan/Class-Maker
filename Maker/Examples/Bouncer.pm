use 5.006; use strict; use warnings;

use Class::Maker;

use Data::Verify qw(verify assess);

our $VERSION = '0.011';

{
	package Bouncer::Test;

	Class::Maker::class
	{
		attribute =>
		{
			string => [qw( field type )],
		},
	};
}

package Bouncer;

Class::Maker::class
{
	attribute =>
	{
		array => { tests => 'Bouncer::Test' },
	},
};

sub inspect : method
{
	my $this = shift;

	my $client = shift or return undef;

		no strict 'refs';

		foreach my $test ( $this->tests )
		{
			my $met = $test->field;

			::croak "'$met' is not a known field of ".ref($client) unless $client->can( $met );

			unless( assess( verify( label => $met, value => $client->$met(), type => $test->type ) ) )
			{
				$@ .= " $met";

				return 0;
			}
		}

return 1;
}

1;
__END__

# Below is stub documentation for your module. You better edit it!

=head1 NAME

Object::Bouncer - Observes/Inspects other objects if they fullfil a list of tests

=head1 SYNOPSIS

  use Object::Bouncer;

	if( A->inspect( B ) )
	{
		print "B is ok";
	}
	else
	{
		print "A rejects B";
	}

=head1 DESCRIPTION

A bouncer in front of a disco makes decisions. He inspects other persons if they meet
the criteria/expectations to be accepted to enter the party or not. The criteria are instructed by
the boss. This is also how Object::Bouncer works.
Object::Bouncer heavily relies on the Verify module.

=head2 EXPORT

None by default.

=head2 EXAMPLE

use Object::Bouncer;

	my $tuersteher = new Object::Bouncer( );

	push @{ $tuersteher->tests },

		new Object::Bouncer::Test( field => 'email', type => 'email' ),

		new Object::Bouncer::Test( field => 'registered', type => 'not_null' ),

		new Object::Bouncer::Test( field => 'firstname', type => 'word' ),

		new Object::Bouncer::Test( field => 'lastname', type => 'word' );

	my $user = new User( email => 'hiho@test.de', registered => 1 );

	if( $tuersteher->inspect( $user ) )
	{
		print "User is ok";
	}
	else
	{
		::carp "rejects User because of unsufficient field:", $@;
	}

None by default.

=head1 PREREQUISITES

Verify

=head1 AUTHOR

Murat Uenalan, muenalan@cpan.org

=head1 SEE ALSO

Verify, L<perl>

=cut
