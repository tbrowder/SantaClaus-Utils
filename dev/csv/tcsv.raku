#!/usr/bin/env raku

use Text::CSV;
use Text::Utils :normalize-string;

my $ifil = "eg.csv";

# I want to get the header as an array of cells.
# Then read one line of data at a time as an
# array of cells.
my @aoa = csv :in("eg.csv");
my @hdr = @(@aoa.shift);
print "|$_|, " for @hdr[0..*-2];
say $_ for @hdr[*-1];

for @aoa -> $row {
    my @row = @($row);
    print "|$_|, " for @row[0..*-2];
    say "|$_|" for @row[*-1];
}


