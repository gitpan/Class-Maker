package Class::Maker::Object::Lockable;

our $VERSION = '0.03';

our $DEBUG;

require 5.005_62; use strict; use warnings;

use Class::Maker;

Class::Maker::class
{
	isa => [qw( Object::Debugable )],

	attribute =>
	{
		bool => [ qw( locked blocked ) ],

		int => [qw( limited passed failed )],

		string => [ qw( passkey unlockkey ) ],
	},
};

use Carp;

# Preloaded methods go here.

sub _preinit
{
	my $this = shift;

		$this->unlockkey(1);

		$this->locked(1);

		$this->blocked(0);

		$this->passed(0);

		$this->limited(5);
}

sub lock
{
	my $this = shift;

		carp 'Closing lock' if $DEBUG;

return $this->locked(1);
}

sub block
{
	my $this = shift;

		carp 'Blocking lock!' if $DEBUG;

return $this->blocked(1);
}

sub unlock
{
	my $this = shift;

		carp 'Opening lock' if $DEBUG;

		if( $this->blocked )
		{
			carp 'Cant unlock, because blocked !' if $DEBUG;

			return $this->locked(1);
		}

return $this->locked(0);
}

sub unblock
{
	my $this = shift;

		carp 'Unblocking lock' if $DEBUG;

return $this->blocked(0);
}

sub try
{
	my $this = shift;

	my %args = @_;

		carp 'Try lock' if $DEBUG;

		if( $this->blocked )
		{
			carp 'Try failed - Lock is blocked !' if $DEBUG;

			return $this->locked;
		}

		if( $this->unlockkey )
		{
			carp 'Require Key' if $DEBUG;

			if( exists $args{KEY} )
			{
				if( $this->passkey eq $args{KEY} )
				{
					carp sprintf "Opening with key '%s'", $args{KEY} if $DEBUG;

					$this->unlock;
				}
			}
			else
			{
				warn 'Key required through ->unlockkey param, but try( KEY => ) is missing';
			}
		}

		if( $this->locked )
		{
			$this->failed( $this->failed + 1 );

			if( $this->failed > $this->limited )
			{
				$this->block();
			}
		}
		else
		{
			$this->failed( 0 );

			$this->passed( $this->passed + 1 );
		}

return $this->locked;
}

sub assert
{
	my $this = shift;

		if( $this->locked )
		{
			print "Wrong Key\n";
		}
		else
		{
			print "Lock passed !\n";
		}
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Object::Lockable - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Object::Lockable;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Object::Lockable, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXAMPLE

my $lock = new Object::Lockable( showpackage => 1, debug => 1, limited => 5 ) or die "unable to instantiate object";

$lock->unlock();

print "Can't pass lock\n" if $lock->try;

$lock->lock();

print "Can't pass lock\n" if $lock->try;

my $key = '1234';

$lock->passkey( $key );

$lock->assert( $lock->try( KEY => $key ) );

$lock->lock();

for( 1..10 )
{
	printf "%d. try\n",$_;

	$lock->assert( $lock->try( KEY => '5678' ) );
}

$lock->assert( $lock->try( KEY => $key ) );

$lock->unblock();

$lock->assert( $lock->try( KEY => $key ) );

$lock->debugDump();

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut
