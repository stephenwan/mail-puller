#!/usr/bin/perl -w
# helper.pl --- 
# Author:  <stephenwan@STEPHEN-PC>
# Created: 15 Sep 2014
# Version: 0.01

use warnings;
use strict;
use Time::Piece;
use YAML;

my $config = {
    
    'target_mailboxes' => [
        {
            'server' => 'mail102@udomain.com.hk',
            'account' => 'stephenwan@udomain.com.hk',
            'password' => { file => '.secret' },
        },                
    ], 

    'mailfetch_opts' => {
        'time_range_max_in_hour' => 24,
        'time_range_min_in_hour' => undef,
        'search_flag' => 'UNSEEN',
        'mark_delete_on_success' => 0,
        'mark_seen_on_success' => 1,
        'mark_seen_on_error' => 1,
        'expunge_immediately' => 1,
        'output_data_dir' => [
            'dev/data', # root
            { template => ':YEAR' },
            { template => ':MONTH' },
            { template => ':DATE' },
            { template => ':MAILBOX' },
            { template => ':TIMESTAMP--:UID' },            
        ],
        'output_meta_dir' => [
            'dev/meta',
            { template => ':YEAR' },
            { template => ':MONTH' },
            { template => ':DATE' },
            { template => ':MAILBOX' },
            { template => ':TIMESTAMP--:UID' },
        ],
        'output_tasklog_dir' => [
            'dev/task',
        ],        
    },

    'log' => undef,

};

open my $fh, '>', 'config.yaml'
    or die "Cannot open file to write.";

print $fh Dump($config), "\n";
print STDOUT "Generated config file at ", localtime->strftime, "\n";

close $fh;

1




__END__

=head1 NAME

helper.pl - Describe the usage of script briefly

=head1 SYNOPSIS

helper.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for helper.pl, 

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
