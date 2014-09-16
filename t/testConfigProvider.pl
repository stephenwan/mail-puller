#!/usr/bin/perl -w
# testConfigProvider.pl --- 
# Author:  <stephenwan@STEPHEN-PC>
# Created: 15 Sep 2014
# Version: 0.01

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use ConfigProvider qw(getconfig);
use Data::Dumper;
use JSON;

use Test::More  tests => 3;

my $config = getconfig();

is ( getconfig('t.ConfigProvider.readscalar'), 'README', 'Configuration access hash');
is ( getconfig('t.ConfigProvider.readarray.1'), 'one', 'Configuration access array');

my $output_dir = getconfig('output_dir');
ok ( $output_dir->{data}  && $output_dir->{meta} && $output_dir->{tasklog}, 'Configuration contains dir information for data,meta,tasklog'); 








__END__

=head1 NAME

testConfigProvider.pl - Describe the usage of script briefly

=head1 SYNOPSIS

testConfigProvider.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for testConfigProvider.pl, 

=head1 AUTHOR

, E<lt>stephenwan@STEPHEN-PCE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
