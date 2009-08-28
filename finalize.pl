
# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself
#
# This is evalled in the package "Aline::Actor::Finalize"
#

use IO::Extended ':all';

printfln "finalize script entered in %s", File::Spec->rel2abs( '.' );

use ExtUtils::Manifest qw(mkmanifest);

mkmanifest();

print qx{perl Makefile.PL};
print qx{pod2text -i2 -l README.pod >README};
print qx{gen_html_from_pod.pl Class};

=pod

may be this should into publish.pl ?

sub create_RESERVE_file
{
   grep -E "package|our" | sort | uniq > RESERVE
}

=cut
