#!/usr/bin/env perl

use strict;
use warnings;

die "Usage: perl get_paste.pl <paste_url_or_number>\n"
    unless @ARGV;

my $What = shift;

use lib '../lib';
use WWW::PastebinCom::Retrieve;

my $paster = WWW::PastebinCom::Retrieve->new;

my $paste = $paster->retrieve( $What )
    or die 'Error: ' . $paster->error . "\n";

print "Paste number $What:\n" . $paste . "\n";