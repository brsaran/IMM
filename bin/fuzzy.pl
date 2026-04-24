#!usr/bin/perl

$pr = `conda run -n OCTAVE octave fuzzy.m $ARGV[0] $ARGV[1] $ARGV[2] $ARGV[3] $ARGV[4]`;
$pr=~/(^[0-9].*)\n/g;
print $1;


