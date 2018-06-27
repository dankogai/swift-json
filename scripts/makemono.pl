#!/usr/bin/env perl
use strict;
use warnings;
use feature ':all';
use FileHandle;
use Fatal;

my $dep    = 'FloatingPointMath';
my $target = 'monoComplex.swift';

sub find {
    my $name = shift;
    use File::Find ();
    my @dirs = ('.build/checkouts');
    my @paths;
    File::Find::find(
        {
            wanted => sub {
                $_ eq $name and push @paths, $File::Find::name;
            }
        },
        @dirs
    );
    die "$name not found" if !@paths;
    return @paths;
}
system qw/swift build/;
my $wfh = FileHandle->new($target, 'w');
for my $fn ( <Sources/Complex/*.swift>, find( $dep . '.swift' ) ) {
    my $rfh = FileHandle->new($fn, 'r');
    for (<$rfh>) {
        next if /\Aimport $dep/;
        $wfh->print($_);
    }
}
