use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::PastebinCom::Retrieve',
    license             => 'perl',
    dist_author         => 'Zoffix Znet <zoffix@cpan.org>',
    dist_version_from   => 'lib/WWW/PastebinCom/Retrieve.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Carp'           => 1.04,
        'URI'            => 1.35,
        'LWP::UserAgent' => 2.036,
    },
    add_to_cleanup      => [ 'WWW-PastebinCom-Retrieve-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
