use Class::Maker qw(class reflect);

class Something;

class Person,
{
	isa => [qw( Something )],

    public =>
    {
            scalar => [qw( name age )],
    },

    private =>
    {
    		scalar => [qw( internal )],
    },
};

sub Person::hello : method
{
	my $this = shift;

	$this->_internal( 2123 );

	printf "Here is %s and i am %d years old.\n",  $this->name, $this->age;
};

sub Person::myfunction
{
}

	my $p = Person->new( name => Murat, age => 27 );

	$p->hello;

	use Data::Dumper;

	print Dumper reflect( Person );
