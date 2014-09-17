package MailDecomposer;

use strict; 
use warnings;

use File::Spec;
use MIME::Words qw /:all/;
use MIME::Parser;
use MIME::Entity;
use Email::Address;
use Data::Dumper;
use Carp;
use Log::Log4perl qw(:easy);
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw();



sub decompose {
    my $target = shift;
    my $meta_options = shift;    
    my $data_options = shift // {};

    my $target_file = $target->{file};
    my $meta_dir = $meta->{dir};
        
    DEBUG('Decompose $target_file');    
    unless (-e $target_flie && -f $target_flie && -r $target_flie) {
        ERROR('Decompose failed: $target_file does not exist or not readable.');
        return undef;        
    }
            
    my ($volume,$directories,$file) = File::Spec->splitpath( $target_file );    
    my ($basename, $ext) = split /[.]/, $file;

    unless ($basename) {
        ERROR('Empty target file basename.');
        return undef;        
    }
    WARN('Target file does not end with eml.') unless $ext eq 'eml';
    
    my $decomposed_to_dir = $data_options->{dir} //
        File::Spec->catdir($directories, $basename.'.decomposed')                            
    DEBUG('Decompose into $decomposed_to_dir');

    my $decomposed_msg_prefix = $data_options->{msg_prefix} // 'msg-decomposed-';        
    DEBUG('Decompose using msg-prefix $decomposed_msg_prefix');
        
    $parser = MIME::Parser->new;
    $parser->output_under($decomposed_to_dir);
    $parser->filer->output_prefix($decomposed_msg_prefix);

    my $_entity = undef;
    eval { $_entity = $parser->parse_open($target_flie) };
    
    if ($@) {
        $results  = $parser->results;
        $decapitated = $parser->last_head;  ### get last top-level head
        ERROR("Parse error: ".$@);        
        DEBUG("Parse results:\n".Dumper($results));
        $parser->filer->purge;        
        return undef;        
    }
    
    DEBUG('Decomposed into $decomposed_to_dir successfully.');        
    1
}


sub _emit_meta {
    
    my $entity = shift;
    my $meta_options = shift;
    
    unless (defined $entity && defined $entity->head) {
        WARN("Cannot extract meta. Provide meta from error-template.");
        return _error_meta();                
    };

    my $head = $entity->head;    
    my $from = eval { _parse_addresses_str($head->get('From')) };
    if ( $@ || !(defined $from && @$from)) {
        ERROR("Invalid email- From: $@ > ". $head->get('From'));
        return undef;        
    }

    my $to = eval { _parse_addresses_str($head->get('To')) };
    if ( $@ || !(defined $to && @$to)) {
        WARN("Invalid email- To: $@ > ". $head->get('To'));        
    }
      
    
    my $cc = eval { _parse_addresses_str($head->get('Cc')) };
    if ( $@) {
        WARN("Invalid email- Cc: $@ > ". $head->get('Cc'));        
    }
            
    my $bcc = eval {_parse_addresses_str ($head->get('Bcc')) };
    if ( $@) {
        WARN("Invalid email- Bcc: $@ > ". $head->get('Bcc'));        
    }

    my $subject = eval { join(' ', decode_mimewords($head->get('Subject'))) };
    if ( $@) {
        WARN("Invalid email subject replaced with default: $@ > " . $head->get('Subject'));        
        $subject = "(Parsing error... > ". $head->get('Subject')." )";        
    }

    
    
    

    
    
    

}

sub _parse_addresses_str {
    my $str = shift;
    chomp $str;    
    return undef unless $str;
    my @addresses = Email::Address->parse($str);
    [ map { {Name => $_->name, Address => $_->address  } } @addresses    ]
}

sub _error_meta_default {
    my $info = shift;    
}


1;

__END__

=head1 NAME

MailDecomposer - Perl extension for blah blah blah

=head1 SYNOPSIS

   use MailDecomposer;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for MailDecomposer, 

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
