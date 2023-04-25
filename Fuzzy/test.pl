#!usr/bin/perl

$pr = `conda run -n OCTAVE octave test.m`;
print $pr;

