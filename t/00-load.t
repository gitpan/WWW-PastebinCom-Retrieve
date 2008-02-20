#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 11;

my $Test_paste_number = 'f3fdae56d';

BEGIN {
    use_ok('Carp');
    use_ok('URI');
    use_ok('LWP::UserAgent');
	use_ok( 'WWW::PastebinCom::Retrieve' );
}

diag( "Testing WWW::PastebinCom::Retrieve $WWW::PastebinCom::Retrieve::VERSION, Perl $], $^X" );

use WWW::PastebinCom::Retrieve;

my $paster = WWW::PastebinCom::Retrieve->new( timeout => 5 );
isa_ok($paster, 'WWW::PastebinCom::Retrieve');
can_ok($paster, qw(new retrieve error paste_number content));


diag("Testing on paste number $Test_paste_number");
my $paste_content = $paster->retrieve( $Test_paste_number );
SKIP: {
    unless ( defined $paste_content ) {
        ok(defined $paster->error, "Error occured, error() must be defined");
        skip "Got retrieve error: " . $paster->error, 4;
    }
    is(
        $paste_content,
        $paster->content,
        'returns from both retrieve() and content() must be the same'
    );
    is(
        $paster->paste_number,
        $Test_paste_number,
        'paste numbers must match the requested one',
    );

    my $content_test = eval "$paste_content";
    if ( $@ ) {
        die "\n\nPaste content seems to not match what we expected it to..."
                . " If the paste http://pastebin.com/f3fdae56d exists"
                . " and contains a Perl hashref, something is wrong"
                . " with this module. Otherwise it's probably fine to"
                . " force the instalation";
    }
    ok(
        exists $content_test->{true},
        "keys of evaled paste hashref (key 'true')"
    );
    ok(
        exists $content_test->{false},
        "keys of evaled paste hashref (key 'false')"
    );
    ok(
        exists $content_test->{time},
        "keys of evaled paste hashref (key 'time')"
    );
}









