our $VERSION = '0.001';

use Class::Maker::Basic::Reflection qw(reflect);

use Class::Maker::Examples::Basket;

{
	package SBasket;

	Class::Maker::class
	{
		version => '0.001',

		isa => [qw(Basket)],

		attribute =>
		{
			getset => [qw( name )],
		},
	};

	sub _preinit
	{
		my $this = shift;

			$this->name( 'Shopping basket' );
	}

	sub _postinit
	{
		my $this = shift;

			$this->{ref($this).'::POST_INIT_CALLED'} = __LINE__;
	}

	sub calc
	{
		my $this = shift;

			my $sum;

			foreach my $key ( $this->get )
			{
				$sum += $key->price();
			}

	return $sum;
	}
}

package SItem;

Class::Maker::class
{
	attribute =>
	{
		getset => [qw( price name desc )],
	},
};

sub _preinit
{
	my $this = shift;

		$this->name( $expect );

		$this->{ref($this).'::PRE_INIT_CALLED'} = __LINE__;
}

sub _postinit
{
	my $this = shift;

		$this->{ref($this).'::POST_INIT_CALLED'} = __LINE__;
}

1;
