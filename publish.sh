#!/usr/bin/sh

make clean

rm -rf /home/Murat/checkout/perl/modules/Class-Maker/PUBLISHED

rm -rf /home/Murat/checkout/perl/modules/publish/projects/Class-Maker/_temp

mkdir /home/Murat/checkout/perl/modules/publish/projects/Class-Maker/_temp

publish.pl --homedir  /home/Murat/checkout/perl/modules/publish --project Class-Maker --targetdir  /home/Murat/checkout/perl/modules/Class-Maker/PUBLISHED --sourcedir  /home/Murat/checkout/perl/modules/Class-Maker

find  /home/Murat/checkout/perl/modules/Class-Maker/PUBLISHED

cd PUBLISHED