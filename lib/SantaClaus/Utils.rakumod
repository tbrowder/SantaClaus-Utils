unit module SantaClaus::Utils;

use Pod::Load;
use Data::Dump;
use Text::Utils :normalize-string;

class TaskEntry is export {
    has $.id;
    has DateTime $.start;
    has DateTime $.end;
    has @.notes is rw;
    has $.employee is rw;
}

class JournalEntry is export {
    has DateTime $.t;
    has @.tasks is rw;
    has $.employee is rw;
}

sub check-task-id(:$user-id!, :$task-id!, :$debug) is export {
    # Check task ID for validity
} # sub check-task-id

sub check-journal($jfil, :$debug = 0) is export {
    my $err = 0;

    if not $jfil.IO.e {
        die "FATAL: The input journal file '$jfil' was not found";
    }
    # Check a journal file for valid syntax
    my $dn = 3; # for debugging

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
        note "ERROR: The \@Pod array should have only one element but it has $pelems";
        ++$err;
    }

    my @pod = @Pod[0].contents;

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

            # possible Task config keys
            my $id     = $p.config<id> // '';
            if not $id {
                note "ERROR: Task is missing a required ':id' config key";
                ++$err;
            }
            if $id eq '?' {
                note "ERROR: Task ':id' value of '$id' is invalid";
                ++$err;
            }
            my $status = $p.config<status> // '';
            my $start  = $p.config<start> // '';
            my $end    = $p.config<end> // '';
            if not ($status or $start or $end) {
                note "ERROR: Task id<$id> is missing one of ':status', ':start', or ':end' config keys";
                ++$err;
            }
            my @c      = $p.contents;
            my $para = "";
            for @c -> $pp {
                next if $pp ~~ Pod::FormattingCode;
                my $ppt = $pp.^name;
                note "DEBUG: pod type '$ppt' at third '$jfil' level" if $debug > $dn;
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
                    $para ~= " $_";
                    note "  normalized text line: |$_|" if $debug;
                }
            }
            if (not $para) and (not ($start or $end)) and $status {
                note "ERROR: Task id<$id> has a ':status' config key but no explanation";
                ++$err;
            }
        }
    }
    $err;

} # sub check-journal

sub add-entry-template($jfil, :$user-id!, :$task-id!, :$debug) is export {
    check-task-id :$user-id, :$task-id; # check validity

    my $fp = open $jfil, :a;
    my $t = DateTime.now;
    my $tnow = sprintf "{$t.year}-%02d-%02dT%02d:%02d", $t.month, $t.day, $t.hour, $t.minute;

    # the standard Entry Pod template
    $fp.say: qq:to/HERE/;

    Z<Edit the following Entry as necessary. Add or delete Z comments as desired.>
    =begin Entry :time<$tnow>
      Z<Enter one of ':start' or ':end' in the following config line if applicable.>
      =begin Task :id<$task-id> :employee<$user-id> :status
        Z<Enter notes and comments here; use blank lines to separate paragraphs>
      =end Task

      Z<Add another Task if applicable; ensure the ':id' is correct before doing so.>
    =end Entry
    HERE

    $fp.close;
} # sub add-entry-template
