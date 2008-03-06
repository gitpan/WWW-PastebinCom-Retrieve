package WWW::PastebinCom::Retrieve;

use warnings;
use strict;

our $VERSION = '0.002';

use Carp;
use URI;
use LWP::UserAgent;

sub new {
    my $class = shift;
    croak "Must have even number of arguments to new()"
        if @_ & 1;
    my %args = @_;
    $args{ +lc } = delete $args{ $_ } for keys %args;

    $args{timeout} ||= 30;

    $args{ua} ||= LWP::UserAgent->new(
            timeout => $args{timeout},
            agent   => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US;'
                        . ' rv:1.8.1.12) Gecko/20080207 Ubuntu/7.10 (gutsy)'
                        . ' Firefox/2.0.0.12',
    );

    return bless \%args, $class;
}

sub retrieve {
    my ( $self, $what ) = @_;

    $self->content( undef );
    $self->paste_number( undef );

    $what =~ s{(?: http:// )? (www\.)? pastebin\.com /}{}ix;
    unless ( defined $what and length $what ) {
        $self->error('Could not make out a paste number or URI');
        return;
    }

    $self->paste_number( $what );

    my $response = $self->{ua}->get( $self->_make_paste_uri( $what ) );
    if ( $response->is_success ) {
        unless ( length $response->content ) {
            $self->error('Got empty paste, this paste ID might not exist.');
            return;
        }
        return $self->content( $response->content );
    }
    else {
        $self->error('Failed to retrieve paste: ' . $response->status_line);
        return;
    }
}

sub _make_paste_uri {
    my ( $self, $paste_number ) = @_;
    my $uri = URI->new('http://pastebin.com/pastebin.php');
    $uri->query_form( dl => $paste_number );
    return $uri;
}

sub error {
    my $self = shift;
    if ( @_ ) {
        $self->{ ERROR } = shift;
    }
    return $self->{ ERROR };
}

sub content {
    my $self = shift;
    if ( @_ ) {
        $self->{ CONTENT } = shift;
    }
    return $self->{ CONTENT };
}

sub paste_number {
    my $self = shift;
    if ( @_ ) {
        $self->{ PASTE_NUMBER } = shift;
    }
    return $self->{ PASTE_NUMBER };
}

=head1 NAME

WWW::PastebinCom::Retrieve - retrieve content of pastes from
L<http://pastebin.com>

=head1 SYNOPSIS

    use strict;
    use warnings;
    
    use lib '../lib';
    use WWW::PastebinCom::Retrieve;

    my $paster = WWW::PastebinCom::Retrieve->new;

    $paster->retrieve('d4b6531a9');

    printf "Paste number %s:\n%sn",
                $paster->paste_number,
                $paster->content;

=head1 DESCRIPTION

The module provides means to retrieve the text from pastes on
L<http://pastebin.com>

=head1 CONSTRUCTOR

=head2 new

    my $paster = WWW::PastebinCom::Retrieve->new;

    my $paster = WWW::PastebinCom::Retrieve->new(
        timeout => 10,
    );

    my $paster = WWW::PastebinCom::Retrieve->new(
        ua => LWP::UserAgent->new(
            timeout => 10,
            agent   => 'PasterUA',
        ),
    );

Constructs and returns a brand new WWW::PastebinCom::Retrieve
object. Takes two arguments, both are I<optional>. Possible arguments are
as follows:

=head3 timeout

    ->new( timeout => 10 );

B<Optional>. Specifies the C<timeout> argument of L<LWP::UserAgent>'s
constructor, which is used for pasting. B<Defaults to:> C<30> seconds.

=head3 ua

    ->new( ua => LWP::UserAgent->new( agent => 'Foos!' ) );

B<Optional>. If the C<timeout> argument is not enough for your needs
of mutilating the L<LWP::UserAgent> object used for retrieving
the pastes, feel free
to specify the C<ua> argument which takes an L<LWP::UserAgent> object
as a value. B<Note:> the C<timeout> argument to the constructor will
not do anything if you specify the C<ua> argument as well. B<Defaults to:>
plain boring default L<LWP::UserAgent> object with C<timeout> argument
set to whatever C<WWW::PastebinCom::Retrieve>'s C<timeout> argument is
set to as well as C<agent> argument is set to mimic Firefox.

=head1 METHODS

=head2 retrieve

    $paster->retrieve('m1dbc0d8')
        or die 'Error: ' . $paster->error;

    my $paste_content = $paster->retrieve('http://pastebin.com/m1dbc0d8')
        or die 'Error: ' . $paster->error;

Instructs the object to retrieve the paste specified as an argument.
B<Takes> one mandatory argument which can be either a full URI to the
paste you wish to retrieve or just its number (or ID if you prefer so).
The "paste number" is basically C<m1dbc0d8> in
C<http://pastebin.com/m1dbc0d8>. B<Returns> the textual content of the
paste, number
or URI of which you have specified. See also C<content()> method described
below. B<If an error occured> C<retrieve()> will return either C<undef>
or an empty list depending on the context and the reason for the error
will be available via C<error()> method (see below).

=head2 error

    $paster->retrieve('m1dbc0d8')
        or die 'Error: ' . $paster->error;

If C<retrieve()> failed to retrieve your paste for any reason it will
return either C<undef> or an empty list depending on the context and
the reason for the error will be available to you via C<error()> method.
Takes no arguments. Returns a human readable reason for the error in
a form of a scalar.

=head2 content

    my $paste_content = $paster->content;

Must be called after a successfull call to C<retrieve()>.
Takes no arguments, returns the content of the retrieved paste in
a form of a scalar.

=head2 paste_number

    $paster->retrieve('http://pastebin.com/m1dbc0d8')
    my $paste_number = $paster->paste_number;
    # $paste_number will contain 'm1dbc0d8'

Must be called after a call to C<retrieve()>. Takes no
arguments, returns the paste number (or ID if you prefer) of the last
paste retrieved.

=head1 AUTHOR

Zoffix Znet, C<< <zoffix at cpan.org> >>
(L<http://zoffix.com>, L<http://haslayout.net>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-pastebincom-retrieve at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-PastebinCom-Retrieve>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::PastebinCom::Retrieve

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-PastebinCom-Retrieve>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-PastebinCom-Retrieve>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-PastebinCom-Retrieve>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-PastebinCom-Retrieve>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Zoffix Znet, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
