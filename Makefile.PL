use inc::Module::Install;

name            'App-TermStyle';
author          "Robert 'phaylon' Sedlacek";
license         'perl';
perl_version    '5.010';

all_from        'lib/App/TermStyle.pm';

requires        'MooseX::App::Cmd',             '0.04';
requires        'Moose',                        '0.65';
requires        'MooseX::Method::Signatures',   '0.06';
requires        'MooseX::Types',                '0.08';
requires        'MooseX::Types::Path::Class',   '0.05';
requires        'MooseX::ClassAttribute',       '0.07';
requires        'MooseX::AttributeHelpers',     '0.14';
requires        'File::HomeDir',                '0.82';
requires        'JSON::Any',                    '1.19';
requires        'List::MoreUtils',              '0.22';
requires        'IPC::System::Simple',          '1.17';
requires        'Carp',                         '1.08';
requires        'aliased',                      '0.22';
requires        'namespace::clean',             '0.09';
requires        'ex::lib',                      '0.04';
requires        'CLASS',                        '1.00';

install_script  'script/term-style';

WriteAll;
