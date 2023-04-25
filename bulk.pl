#! usr/bin/perl

open(FILE,"geneSrt");
@fi = <FILE>;
close(FILE);

for($i=0;$i<@fi;$i=$i+2){
	$cnt++;	
	$seq = $fi[$i].$fi[$i+1];
	open(FILE,">fasta");
	print FILE $seq;
	close(FILE);
	$y = `perl IMM fasta >>log.out 2>error.log`;
	print "$cnt Completed\t $fi[$i]\n";
	
}
