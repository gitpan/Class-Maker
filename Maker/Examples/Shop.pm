our $VERSION = '0.001';

use Class::Maker::Basic::Reflection qw(reflect);

use Class::Maker::Examples::Basket;

Class::Maker::class 'SBasket',
{
	version => '0.001',

	isa => [qw(Basket)],

	attribute =>
	{
		getset => [qw( name )],
	},
};

sub SBasket::_preinit
{
	my $this = shift;

		$this->name( 'Shopping basket' );
}

sub SBasket::_postinit
{
	my $this = shift;

		$this->{ref($this).'::POST_INIT_CALLED'} = __LINE__;
}

sub SBasket::calc
{
	my $this = shift;

		my $sum;

		foreach my $key ( $this->get )
		{
			$sum += $key->price();
		}

return $sum;
}

class 'SItem',
{
	attribute =>
	{
		getset => [qw( price name desc )],
	},
};

sub SItem::_preinit
{
	my $this = shift;

		$this->name( $expect );

		$this->{ref($this).'::PRE_INIT_CALLED'} = __LINE__;
}

sub SItem::_postinit
{
	my $this = shift;

		$this->{ref($this).'::POST_INIT_CALLED'} = __LINE__;
}

1;
