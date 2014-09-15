package ConfigProvider;

use strict; 
use warnings;

use Carp;
use YAML qw(LoadFile);
use Exporter;
use FindBin;
use Data::Dumper;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( getconfig );

my $config_file_path = "$FindBin::Bin/../conf/config.yaml";
my $_config;


sub getconfig {
    my $query = shift;
    _read_config() unless defined $_config;

    return $_config unless $query;
        
    my @query_pieces = split /[.]/, $query;

    my $tracer = $_config;    
    while ( defined($tracer) && defined(my $piece = shift @query_pieces)) {                
        if ( ref $tracer eq 'HASH') {
            $tracer = $tracer->{$piece};                
        } elsif ( ref $tracer eq 'ARRAY') {
            $tracer = $tracer->[$piece];            
        } else {
            $tracer = $tracer == $piece?$tracer:undef;            
            last;            
        }
    }
    $tracer    
}

sub _read_config {
    open my $fh, '<', $config_file_path
        or die "Cannot read the config file.";
    $_config = LoadFile($fh);    
    close $fh;    
}

1;


__END__

=head1 NAME

ConfigProvider - Perl extension for blah blah blah

=head1 SYNOPSIS

   use ConfigProvider;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for ConfigProvider, 

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
