package Array;

our $VERSION = '0.1.4';

use Array::Compare;

require Algorithm::FastPermute;

Class::Maker::class
{
	public =>
	{
		getset => [qw( max )],
	},

	private =>
	{
		array => [qw( array )],
	},
};

sub _preinit
{
	my $this = shift;

	my $args = shift;

		# Manipulate args list, because otherwise teh Class::Maker constructor would forward args
		# for inhertance

	if( defined $args )
	{
		$this->_array( $args->{array} ) if exists $args->{array};

		delete $args->{array};
	}
}

sub push : method
{
	my $this = shift;

	push @{ $this->_array }, @_;
}

sub pop : method
{
	pop @{ shift->_array };
}

sub shift : method
{
	my $this = shift;

return shift @{ $this->_array };
}

sub unshift : method
{
	my $this = shift;

return unshift @{ $this->_array }, @_;
}

sub count : method
{
	scalar @{ shift->_array };
}

sub reset : method
{
	@{ shift->_array } = ();
}

sub get : method
{
	@{ shift->_array };
}

sub pick : method
{
	my $this = shift;

		my $step = shift || 2;

		my @result;

		my $cnt;

		map { push @result, $_ unless $cnt++ % $step } @{ $this->_array };

return Array->new( array => \@result );
}

sub every : method
{
	pick( @_ );
}

sub join : method
{
	my $this = shift;

return join( shift, @{ $this->_array } );
}

sub sort : method
{
	my $this = shift;

	my $alpha = shift;

		if( $alpha )
		{
			$this->_array( [sort { $a cmp $b } @{ $this->_array }] ) ;
		}
		else
		{
			$this->_array( [sort { $a <=> $b } @{ $this->_array }] );
		}

return $this;
}

# from the perlfaq:
# fisher_yates_shuffle( \@array ) :
# generate a random permutation of @array in place
sub _fisher_yates_shuffle
{
    my $array = shift;

    my $i;

    for ($i = @$array; --$i; )
    {
        my $j = int rand ($i+1);

        @$array[$i,$j] = @$array[$j,$i];
    }
}

sub rand : method
{
	my $this = shift;

		_fisher_yates_shuffle( scalar $this->_array );

return $this;
}

sub _algebra
{
	my $this = shift;

	my $type = shift;

		my $other = shift;

		$other = ref($other) eq 'ARRAY' ? $other : [ $other->_array ];

return Array->new( array => _calc( [ $this->_array ], $other )->[$type] );
}

sub union : method
{
	my $this = shift;

return $this->_algebra( 0, @_ );
}

sub intersection : method
{
	my $this = shift;

return $this->_algebra( 1, @_ );
}

sub diff : method
{
	my $this = shift;

return $this->_algebra( 2, @_ );
}

sub _calc
{
	my ( $a, $b ) = @_;

	die 'argument type mismatch for _calc( aref, aref )' unless ref($a) eq 'ARRAY' && ref($a) eq 'ARRAY';

	my @array1 = @$a;

	my @array2 = @$b;

	no strict;

	@union = @intersection = @diff = ();

	%count = ();

	foreach $element (@array1, @array2) { $count{$element}++ }

	foreach $element (keys %count)
	{
	    push @union, $element;

	    push @{ $count{$element} > 1 ? \@intersection : \@diff }, $element;
	}

return [ \@union, \@intersection, \@diff ];
}

sub eq : method
{
	my $this = shift;

	my $that = shift;

	my $comp = Array::Compare->new;

return $comp->compare( scalar $this->_array , scalar $that->_array );
}

sub ne : method
{
	my $this = shift;

	my $that = shift;

return not $this->eq( $that );
}

sub totext : method
{
	my $this = shift;

return '['.join( '], [', @{ $this->_array } ).']';
}

sub sum : method
{
	my $this = shift;
	
	my $sum;
	
	$sum += $_ foreach @{ $this->_array };

return $sum;
}

sub unique : method
{
	my $this = shift;

	my %temp;
	
		@temp{ @{ $this->_array } } = 1;
	
		@{ $this->_array } = keys %temp;
	
return $this;
}

sub permute : method
{
	my $this = shift;

		my @result;

		my $p = Algorithm::FastPermute::permute { push @result, $_ } ( @{ $this->_array } );
		
		@{ $this->_array } = @result;

return $this;
}

1;

__END__

=head1 NAME

Array - a complete array class

=head1 SYNOPSIS

  use Class::Maker::Examples::Array;

	Array->new( array => [1..100] );

		# standard

	$a->shift;

	$a->push( qw/ 1 2 3 4 / );

	$a->pop;

	$a->unshift( qw/ 5 6 7 / );

	$a->reset;

	$a->join( ', ' );

		# extended

	$a->count;

	$a->get;

	$a->pick( 4 );

	$a->union( 100..500 );

	$a->intersection( 50..100 );

	$a->diff( 50..100 );

	$a->rand;

	$a->sort;

	$a->totext;

	$a->sum;
	
	$a->unique;

	$a->permute;

	print "same" if $a->eq( $other );
	
=head1 DESCRIPTION

This an object-oriented array class, which uses a method-oriented interface.

=head1 METHODS

Mostly they have the similar syntax as the native perl functions (use "perldoc -f"). If not they are
documented below, otherwise a simple example is given.

=head2 count

Returns the number of elements (same as @arry in scalar context).

=head2 reset

Resets the array to an empty array.

=head2 get

Returns the backend array.

=head2 pick( [step{scalar}]:2 )

Returns every 'step' (default: 2) element.

=head2 union

Returns the union of two arrays (Array object is returned).

=head2 intersection

Returns the intersection of the two arrays (Array object is returned).

=head2 diff

Returns the diff of the two arrays (Array object is returned).

=head1 EXPORT

None by default.

=head1 EXAMPLE

=head2 Purpose

Because most methods return Array objects itself, the can be easily further treated with Array methods.
Here a rather useless, but informative example.

=head2 Code

use Class::Maker::Examples::Array;

	my $a = Array->new( array => [1..70] );

	my $b = Array->new( array => [50..100] );

	$a->intersection( $b )->pick( 4 )->join( ', ' );

=head1 AUTHOR

Murat Uenalan, muenalan@cpan.org

=head1 SEE ALSO

L<perl>, L<perlfunc>, L<perlvar>

=cut
