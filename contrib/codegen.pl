use Class::Maker;
use Class::Maker::Generator;

shift;

my $gen = Class::Maker::Generator->new( source => $_, type => 'FILE', lang => 'perl' );

print $gen->output;

