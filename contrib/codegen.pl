
# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself
use Class::Maker;
use Class::Maker::Generator;

shift;

my $gen = Class::Maker::Generator->new( source => $_, type => 'FILE', lang => 'perl' );

print $gen->output;

