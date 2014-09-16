package ImapFetcher;

use strict; 
use warnings;
use Log::Log4perl qw(:easy);

use Carp;
use Exporter;
use Net::IMAP::Simple;
use Time::Piece;
use Time::Seconds;
use File::Spec;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(download_email_source);

sub _gen_imap_search_term {
    my ($search_flag, $time_range_max_in_day, $time_range_min_in_day) = @_;

    my @pieces = ();
    push @pieces, $search_flag if $search_flag;
    
    if (defined $time_range_min_in_day) {
        my $ts = Time::Seconds->new( $time_range_min_in_day * 24 * 3600);
        my $t = localtime;
        $t -= $ts;
        $t += ONE_DAY;        
        push @pieces, 'BEFORE '.$t->strftime('%d-%b-%Y');                
    }

    if (defined $time_range_max_in_day) {
        my $ts = Time::Seconds->new( $time_range_max_in_day * 24 * 3600);
        my $t = localtime;
        $t -= $ts;
        push @pieces, 'SINCE '.$t->strftime('%d-%b-%Y');        
    }

    join ' ', @pieces    
}

sub _gen_source_filename {
    my $uid = shift;
    my $t = localtime;
    $t->epoch . '_'.$uid.'.eml'    
}


sub download_email_source {
    my ($conn_info, $dest, $options) = @_;
    
    my $imap = Net::IMAP::Simple->new($conn_info->{server});
    
    unless ($imap) {
        ERROR $conn_info->{account}."> Unable to connect to ".$conn_info->{server};
        return undef;        
    } else {
        INFO $conn_info->{account}."> Connected.";        
    }

    unless ($imap->login($conn_info->{account}, $conn_info->{password}) ) {
        ERROR $conn_info->{account}."> Unable to connect:".$imap->errstr;
        return undef;  
    } else {
        INFO $conn_info->{account}."> Login successful.";        
    }
    
    unless (defined $conn_info->{folders} && @{$conn_info->{folders}}) {
        $conn_info->{folders} = ['INBOX'];
        DEBUG "Default folder set to INBOX";        
    }
        
    for my $folder ( @{$conn_info->{folders}} ) {
        
        DEBUG "Entering $folder";
        
        my $mn = $imap->select($folder);
        unless ( defined $mn) {
            ERROR($conn_info->{account}.">$folder".
                      "> Cannot select: ".$imap->errstr);
            next
        }    

        my $search_term = _gen_imap_search_term(
            $options->{search_flag}, $options->{time_range_max_in_day}, $options->{time_range_min_in_day});
        
        DEBUG "Search term used to fetch email uids: ". $search_term;
        
        my @msg_ids = $imap->search($search_term);        
        my $counter = 0;
        my $_success;
        my $_uid;
        
        for my $msg_id (@msg_ids ) {
            $_success = 0;
            
            ($_uid) = $imap->uid($msg_id);
            
            DEBUG "mail message id $msg_id uid $_uid";            
            
            unless ( $_uid) {
                WARN $conn_info->{account}.">$folder"."> Cannot fetch uid for mail $msg_id.";
                next
            }
            
            my $source_fh = $imap->getfh($msg_id);
            unless ( defined $source_fh) {
                WARN $conn_info->{account}.">$folder"."> Cannot read from mail $_uid.";
                next                
            }

            my $write_to_file = File::Spec->catfile($dest, _gen_source_filename($_uid));
            open my $write_to_fh, '>', $write_to_file;            
            unless ($write_to_fh) {
                ERROR $conn_info->{account}.">$folder"."> Cannot write to file $write_to_file.";
                return undef;                    
            }

            my $_line;            
            while ($_line = <$source_fh>) {
                chomp $_line;                
                print $write_to_fh $_line;                
            }
            
            close $write_to_fh;            
            close $source_fh;

            INFO $conn_info->{account}.">$folder"."> mail $_uid saved at $write_to_file.";
            $counter += 1;
            $_success = 1;
                                               
        } continue {
            if ( $_success ) {
                if ( $options->{mark_delete_on_success}) {
                    if ($imap->delete($msg_id)) {
                        DEBUG "mail $_uid has been mark delete.";                    
                    } else {
                        WARN $conn_info->{account}.">$folder".
                            "> Cannot mark delete mail $_uid: ".$imap->errstr; 
                    }
                }
                if (defined $options->{mark_seen_on_success} && !$options->{mark_seen_on_success}) {
                    if ( $imap->unsee($msg_id)) {
                        DEBUG "mail $_uid has been mark unseen.";                    
                    } else {
                        WARN $conn_info->{account}.">$folder".
                            "> Cannot mark unseen mail $_uid: ".$imap->errstr; 
                    }                
                } else {
                    if ( $imap->see($msg_id)) {
                        DEBUG "mail $_uid has been mark seen.";                    
                    } else {
                        WARN $conn_info->{account}.">$folder".
                            "> Cannot mark seen mail $_uid: ".$imap->errstr; 
                    }  
                }                
            } else {
                if ( defined $options->{mark_seen_on_error} && !$options->{mark_seen_on_error}) {
                    if ( $imap->unsee($msg_id)) {
                        DEBUG "mail $_uid has been mark unseen.";                    
                    } else {
                        WARN $conn_info->{account}.">$folder".
                            "> Cannot mark unseen mail $_uid: ".$imap->errstr; 
                    }   
                } else {
                    if ( $imap->see($msg_id)) {
                        DEBUG "mail $_uid has been mark seen.";                    
                    } else {
                        WARN $conn_info->{account}.">$folder".
                            "> Cannot mark seen mail $_uid: ".$imap->errstr; 
                    }  
                }  
            }                                                                  
        }
        
        INFO $conn_info->{account}.">$folder"."> Saved $counter messages.";  
    }
        
    $imap->quit;
    INFO $conn_info->{account}."> Quit.";

    1
}



1;
__END__

=head1 NAME

ImapFetcher - Perl extension for blah blah blah

=head1 SYNOPSIS

   use ImapFetcher;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for ImapFetcher, 

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

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
