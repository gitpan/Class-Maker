
# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself
use 5.008002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Class::Maker',
    VERSION_FROM      => 'lib/Class/Maker.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Class/Maker.pm', # retrieve abstract from module
       AUTHOR         => 'A. U. Thor <a.u.thor@a.galaxy.far.far.away>') : ()),
);
