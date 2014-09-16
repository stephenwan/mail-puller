package PathManager;

use strict; 
use warnings;

use Carp;
use Exporter;
use Time::Piece;
use File::Spec;
use File::Path qw(make_path);

our @ISA = qw(Exporter);

my $_dynamic_vars;
my $_cached_interpolated_vars;

sub translate_path {    
    my $path_piece_array = shift;
    my $_dynamic_vars = shift // {};
    my $create_if_not_exists = shift // 1;
        
    my $path = File::Spec->catdir(
        map { (ref $_ eq 'HASH')?
                  _render_template($_->{template}): $_
              }  @$path_piece_array);

    make_path($path) if $create_if_not_exists;
    $path
}




sub _fetch_interpolatable_values {    
    my $t = localtime;
    $_cached_interpolated_vars = {
        ':YEAR' => $t->year,
        ':MONTH' => $t->mon,
        ':DATE' => $t->mday,
        ':TIMESTAMP' => $t->epoch,
        ':MAILBOX' => $_dynamic_vars->{mailbox} // "",
        ':FOLDER' => $_dynamic_vars->{folder} // "",
        ':UID' => $_dynamic_vars->{uid} // "",
    };
    $_cached_interpolated_vars
}

sub _render_template {
    my $template = shift // '';
    my $vars = $_cached_interpolated_vars // _fetch_interpolatable_values();
    $template =~ s/:[A-Z]+\b/(defined $vars->{$&})?$vars->{$&}:$&/eg;
    $template
}



1;


__END__

=head1 NAME

PathManager - Perl extension for blah blah blah

=head1 SYNOPSIS

   use PathManager;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for PathManager, 

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
