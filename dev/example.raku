#!/usr/bin/env raku
use Pod::Load;
use Data::Dump;
use Text::Utils :normalize-string;

my $jfil = "example.pod";
my $jstr = slurp $jfil;

my @pod = load $jstr;
say Dump(@pod, :color(False), :no-postfix(False), :skip-methods(True));
