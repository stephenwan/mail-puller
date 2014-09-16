#!/usr/bin/perl -w
# testImapFetcher.pl --- 
# Author:  <stephenwan@STEPHEN-PC>
# Created: 16 Sep 2014
# Version: 0.01

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use ImapFetcher qw(download_email_source);

use Log::Log4perl qw(:easy);
use Test::More tests => 1;

my $conn_info = {
    account => 'stephentest@126.com',
    password => 'testpassword',
    server => 'imap.126.com',
};

my $dest = 'output/';
my $options = {
    search_flag => 'UNSEEN',
    time_range_max_in_day => 0,
    time_range_min_in_day => 0,
    mark_seen_on_success => 1,
};

#Log::Log4perl->easy_init($DEBUG);

ok(download_email_source($conn_info, $dest, $options), "Basic run ok.");



    


__END__

=head1 NAME

testImapFetcher.pl - Describe the usage of script briefly

=head1 SYNOPSIS

testImapFetcher.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for testImapFetcher.pl, 

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
