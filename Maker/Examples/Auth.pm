require 5.005_62; use strict; use warnings;

use class;

use Object::Expirable;

::class 'Object::Auth',	
{
	isa => [ qw( Object::Expirable ) ],
		
	attribute =>
	{
		bool => [ qw( isin ) ],
		
		int => [ qw( logincount passfailed ) ],
		
		string => [ qw( userid passwd lastvisitdate passlastfailed ) ],
	},
};

our $VERSION = '0.02';

# Preloaded methods go here.

sub Object::Auth::_preinit
{
	my $this = shift;

		$this->logincount( 0 );

		$this->passfailed( 0 );

		$this->isin(0);
}

sub Object::Auth::login : method
{
	my $this = shift;

	my $passwd = shift || die __PACKAGE__."login() needs a defined passwd argument";

	#$this->debugPrint( sprintf "LOGIN COMPARE '%s' '%s'\n", $this->passwd, $passwd );

	if( $this->passwd && defined $passwd )
	{
		if( $this->passwd eq $passwd)
		{
			#$this->debugPrint( sprintf "'%s' comes in..\n\n", $this->userid );

			$this->lastvisitdate( time );

			$this->logincount( $this->logincount + 1 );

			$this->isin(1);

			return 1;
		}
	}

	$this->passfailed( $this->passfailed + 1 );

	$this->passlastfailed( time );

	$this->isin(0);

return undef;
}

sub Object::Auth::logout : method
{
	my $this = shift;

	#$this->debugPrint( sprintf "'%s' logged out !\n\n", $this->userid );

	$this->isin(0);
}

1;
__END__

# Below is stub documentation for your module. You better edit it!

=head1 NAME

CATS::Loginable - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CATS::Loginable;

=head1 DESCRIPTION

Stub documentation for CATS::Attachment, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut
