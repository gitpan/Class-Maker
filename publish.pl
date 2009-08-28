#!/usr/bin/perl -w

# (c) 2008 by Murat Uenalan. All rights reserved. Note: This program is
# free software; you can redistribute it and/or modify it under the same
# terms as perl itself

use strict; use warnings;

### Standard Getopt::Long / Pod::Usage header ###

use Getopt::Long;

use Pod::Usage;

	my $DEBUG=0;

	my %options = ();

	my @config = qw/help|? man sourcedir=s targetdir=s homedir=s project=s/;

	GetOptions( \%options, @config ) or pod2usage(2);

	pod2usage(1) if exists $options{'help'} || not keys %options;

	pod2usage( exitstatus => 0, verbose => 2 ) if exists $options{'man'};

#
# Author:	Murat Uenalan (muenalan@cpan.org)
#

our $VERSION = '0.01';

#$Class::Listener::DEBUG = 1;

use Workflow::Aline;

use IO::Extended qw(:all);

our $master = Workflow::Aline->new( 
									 
			  source_dir => $options{sourcedir}, 
			  
			  target_dir => $options{targetdir}, 
			  
			  home_dir => $options{homedir},
			  
			  comp_dir   => Path::Class::Dir->new( $options{homedir}, 'projects', $options{project} ),
			  
			  temp_dir   => Path::Class::Dir->new( $options{homedir}, 'projects', $options{project}, '_temp' ),
			  
			  is_testrun => 0,
			  
			  stages => 2,
			  
			  stage_dir_format => Path::Class::Dir->new( 'stage%d/Class' )->stringify,
			  
			  robots => 
			  [ 
			    Workflow::Aline::Robot::Finalize->new(),		    
		    ],
			  );

print $master->dump;

our $templ_robot = Workflow::Aline::Robot::Template->new( detector => sub { $_[1] =~ /\.tmpl$/ } );

our $decorator_robot = Workflow::Aline::Robot::Decorator->new( stage => 0 );

our $podchecker_robot = Workflow::Aline::Robot::Podchecker->new();

our $mkdir_robot = Workflow::Aline::Robot::Mkdir->new();

our $filecopy_robot = Workflow::Aline::Robot::Copy->new();

our $masskip_robot = Workflow::Aline::Robot::Skip->new( when => sub { my ($this, $event, $session, $src) = @_; $src->stringify =~ /maslib|cvs/i } );

our $tmplskip_robot = Workflow::Aline::Robot::Skip->new( when => sub { my ($this, $event, $session, $src) = @_; $src->stringify =~ /tmpl$/ && not $session->master->is_staging } );

our $tempskip_robot = Workflow::Aline::Robot::Skip->new( when => sub { my ($this, $event, $session, $src) = @_; $src->stringify =~ /~$/i } );

		#$podchecker_robot is too verbose and out
		
our @robots = ( 
		$tempskip_robot, 
		$masskip_robot, 
		$tmplskip_robot, 
		$mkdir_robot, 
		$filecopy_robot, 
		$templ_robot, 
		$decorator_robot );		

$master->run( @robots );

$master->close;

println "Exiting $0";

__END__

__END__

=head1 NAME

publish - aline publishing utility

=head1 SYNOPSIS

publish [options] [file ...]

 Options:

   -help            brief help message
   -man             full documentation

   -command=s@		a list of commands
   -file			textfile with filenames
   -glob			glob expression
   -dir				define other than current dir (for globbing)

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-command>

a list of shell commands

=item B<-file>

on every line in this file

=item B<-glob>

on every item from this glob

=item B<-dir>

define other than current dir (for globbing only)

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 Example

- 'ls -la' on all perlscript files in the perlbin directory

	do -g *.pod -d perlbin

- print all pod documentation (in the perlbin directory)

	do -c perldoc -g *.pod -d perlbin

- cat all perlscript

	do -c cat -g *.pl

- gunzip all .gz files

	do -c gunzip -g *.gz

- untar all tarfiles and then remove the archives

	do -c "tar xvf" -c "rm" -g *.tar

  ! warning: vice versa in the commands order would be fatal !

=cut
