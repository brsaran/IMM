#! usr/bin/perl


my $fname = $ARGV[0];
$fname=~s/\s//g;

if(open(FASTA, "$fname")){ 
	my @oriF = <FASTA>;
	@oriF = @oriF[1 .. $#oriF ];
	$oriS = join("",@oriF);
	$oriS=~s/\s//g;
	#print "\nFile open Success!";
	save_F('9mer',split9($oriS));
	save_F('12mer',split12($oriS));
	#save_F('15mer',split15($oriS));
	#my $c_date = `date +"%d_%m_%Y_%H_%M_%S"`;
	#chop($c_date);
	my $dir = "temp";
	#`mkdir $dir`;
	`mv 9mer 12mer $dir`;
	`cp $fname $dir/fasta`;
	print "1";
}
else{ 
	print "Couldn't open file $fname, $!"; exit;
}



sub split9{
	my $out="";
	my $seq = $_[0];
	for(my $Ni=0;$Ni<(length($seq)-8);$Ni++){
		$out.=substr($seq,$Ni,9)."\n";
	}
	return $out;
}
sub split12{
	my $out="";
	my $seq = $_[0];
	for(my $Ni=0;$Ni<(length($seq)-11);$Ni++){
		$out.=substr($seq,$Ni,12)."\n";
	}
	return $out;
}

sub split15{
	my $out="";
	my $seq = $_[0];
	for(my $Ni=0;$Ni<(length($seq)-14);$Ni++){
		$out.=substr($seq,$Ni,15)."\n";
	}
	return $out;
}
sub save_F{
	my $fnam = $_[0];
	my $fcon = $_[1];
	if(open(FILE,">$fnam")){
		print FILE $fcon;
		close(FILE);
	}else{
		print "Couldn't create file $fnam, $!"; exit; 
	}
	#print "\nSplit save Success!";
}
