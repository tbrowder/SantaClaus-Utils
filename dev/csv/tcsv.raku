#!/usr/bin/env raku

use Text::CSV;
use Text::Utils :normalize-string;

my $ifil = "eg.csv";

# I want to get the header as an array of cells.
# Then read one line of data at a time as an
# array of cells.
my @aoa = csv :in("eg.csv");
my (@hdr, @rows);


for @aoa.kv -> $idx, $row {
    my @cells;
    my @arr = @($row);
    next if not @arr.elems;
    for @arr -> $cell is copy {
        $cell = normalize-string $cell;
        if $idx {
            @cells.push: $cell;
        }
        else {
            @hdr.push: $cell;
        }
    }
    @rows.push(@cells) if $idx and @cells.elems == @hdr.elems;
}

# now display results
print "|$_|, " for @hdr[0..*-2];
say "|$_|" for @hdr[*-1];
for @rows -> $row {
    my @row = @($row);
    print "|$_|, " for @row[0..*-2];
    say "|$_|" for @row[*-1];
}

=finish
my @hdr = @(@aoa.shift);
print "|$_|, " for @hdr[0..*-2];
say $_ for @hdr[*-1];
for @aoa -> $row {
    my @row = @($row);
    print "|$_|, " for @row[0..*-2];
    say "|$_|" for @row[*-1];
}


