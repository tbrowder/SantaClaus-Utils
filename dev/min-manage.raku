#!/usr/bin/env raku
use Pod::Load;
use Data::Dump;
use Text::Utils :normalize-string;

use SantaClaus::Utils;

my $jfil = "journal";
my $jstr = "";

# make sure the whole file is considered pod
# without the user being aware
# CAUTION @pod array should have only 1 element
$jstr ~= "=begin pod\n";
$jstr ~= slurp $jfil;
$jstr ~= "\n=end pod";

my @Pod = load $jstr; #$jfil;
my $pelems = @Pod.elems;
if $pelems != 1 {
    die "FATAL: The \@Pod array should have only one element but it has $pelems";
}

my @pod = @Pod[0].contents;
for @pod {
    next if $_ ~~ Pod::FormattingCode;
    my $Pt = $_.^name;
    next unless $Pt eq "Pod::Block::Named";
    my $Pn = $_.name;
    next unless $Pn eq 'Entry';

    unless $_.config<time>:exists {
        die "FATAL: Unexpected '$Pn' without 'time' config key";
    }
    my $Ts = $_.config<time>;
    my @C  = $_.contents;
    for @C -> $p {
        next if $p ~~ Pod::FormattingCode;
        my $pt = $p.^name;
        next unless $pt eq "Pod::Block::Named";
        my $pn = $p.name;
        next unless $pn eq 'Task';

        # possible Task config keys
        my $id     = $p.config<id> // '';
        die "FATAL: Task is missing a required ':id' config key" if not $id;
        my $status = $p.config<status> // '';
        my $start  = $p.config<start> // '';
        my $end    = $p.config<end> // '';
        die "FATAL: Task id<$id> is missing one of ':status', ':start', or ':end' config keys"
            if not ($status or $start or $end);
        my @c      = $p.contents;
        for @c -> $pp {
            next if $pp ~~ Pod::FormattingCode;
            my @cc = $pp.contents;
            for @cc {
                next if $_ ~~ Pod::FormattingCode;
                next if $_ !~~ /\S/;
                $_ = normalize-string $_; # text para
            }
        }
    }
}
