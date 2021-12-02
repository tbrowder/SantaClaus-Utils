unit class SantaClaus::PSTable is export;

use Font::AFM;

constant \DEFAULT-FONT-SIZE = 12;
constant \DEFAULT-HDR-FONT = 'Times-Bold';
constant \DEFAULT-ROW-FONT = 'Times-Roman';

class Fnt {
    has Font::AFM $.font;
    has $.name;
    has $.size;
}

=begin comment
my $font = "Times-Roman";
my $fontsize = 12;
my $afm = Font::AFM.new($font);
my $width = $afm.stringwidth($string, $fontsize);


The purpose of this class is to provide enough
information about its data to create a PostScript version.
Thus it must provide the following to the caller:

+ min width of each column for its content and font
+ min height of each row for its content and font

While each cell can have its own font, it is generally
better to have row 0 be the header and the other rows
contain the data.  The default is to use Times-Roman 
for the data and Times-Bold for the header row.

=end comment

class Cell {...}
class Row {...}

# the table should keep a rectangular shape by
# ensuring all rows have the same number of cells, whether empty or not
has $.ncols;
has $.nrows; 

has $.hfont-size = 12;
has $.rfont-size = 12;
has $.row-hpad;
has $.hdr-hpad;
has $.row-vpad;
has $.hdr-vpad;

has @.rows;

has Fnt $.hdr-font;
has Fnt $.row-font;

submethod TWEAK {
    # mainly set default fonts
    
}

method set-hdr-font(:$name, :$size = 12) {
    $!hdr-font = 
my $afm = Font::AFM.new($font);
}
method set-row-font(:$name, :$size = 12) {
}

method import-csv($fname) {

}

method xy-dimens(--> List) {
    # return the x and y dimensions of the table in PS points
 
}

method write-ps($fp, 
                :$xul, :$yul, # location to print the upper-left corner of the page, in PS points (72 per inch)
                :$debug) {
    $fp.say: qq:to/HERE/;
    gsave $xul $yul translate 0 0 moveto
    HERE
}

class Cell {
    has $.content; # a string or number
    has $.font;
}

