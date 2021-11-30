#!/usr/bin/env raku
use Pod::Load;
use Data::Dump;
use Text::Utils :normalize-string;

use SantaClaus::Utils;

my $debug = @*ARGS.elems ?? 1 !! 0;
my $dn = 3; # for debugging

my $jfil = "journal";
my $jstr = "";

# make sure the whole file is considered pod
# without the user being aware
# CAUTION @pod array should have only 1 element
$jstr ~= "=begin pod\n";
$jstr ~= slurp $jfil;
$jstr ~= "\n=end pod";

class Task {
    has $.id;
    has DateTime $.start;
    has DateTime $.end;
    has @.notes is rw;
}

my class JEntry {
    has DateTime $.t;
    has @.tasks is rw;
}

my @Pod = load $jstr; #$jfil;
my $pelems = @Pod.elems;
if $pelems != 1 {
    die "FATAL: The \@Pod array should have only one element but it has $pelems";
}

my @pod = @Pod[0].contents;
# pod format
# [
#   Pod::Block::Named .name = Entry
#     [
#   Pod::Block::Named .name = Entry
#   ...
# ]

#say Dump(@pod, :color(False), :no-postfix(True), :skip-methods(True));
note "Say \$debug set to $debug; \$dn = $dn" if $debug;

for @pod {
    next if $_ ~~ Pod::FormattingCode;

    my $Pt = $_.^name;
    unless $Pt eq "Pod::Block::Named" {
        note "DEBUG: skipping pod type '$Pt' at top level" if $debug > $dn;
        next;
    }
    my $Pn = $_.name;
    unless $Pn eq 'Entry' {
        note "DEBUG: skipping pod type '$Pt', name '$Pn' at top level" if $debug > $dn;
        next;
    }
    note "Found Entry line" if $debug;

    unless $_.config<time>:exists {
        say Dump($_, :color(False), :no-postfix(True), :skip-methods(True));
        die "FATAL: Unexpected '$Pn' without 'time' config key";
    }
    my $Ts = $_.config<time>;
    my @C  = $_.contents;
    for @C -> $p {
        next if $p ~~ Pod::FormattingCode;
        my $pt = $p.^name;
        unless $pt eq "Pod::Block::Named" {
            if $debug > $dn {
                note "DEBUG: skipping pod type '$pt' at second level";
                my $c = $p.contents.join(' ');
                note "  contents: |$c|";
            }
            next;
        }
        my $pn = $p.name;
        next unless $pn eq 'Task';
        note "Found Task line" if $debug;

        # possible config keys
        my $status = $p.config<status> // '';
        my $start  = $p.config<start> // '';
        my $end    = $p.config<end> // '';
        my $id     = $p.config<id> // '';
        my @c      = $p.contents;
        for @c -> $pp {
            next if $pp ~~ Pod::FormattingCode;
            my $ppt = $pp.^name;
            note "DEBUG: pod type '$ppt' at third level" if $debug > $dn;
            my @cc = $pp.contents;
            for @cc {
                my $t = $_.^name;
                if $debug > $dn {
                    note "DEBUG: pod type '$t' at 4th level";
                    note "  |$_|";
                }
                next if $_ ~~ Pod::FormattingCode;
                next if $_ !~~ /\S/;
                $_ = normalize-string $_;
                note "  normalized text line: |$_|" if $debug;
            }
        }
    }
}
