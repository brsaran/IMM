#! usr/bin/perl

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^mixmhc2\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;

	if($conda_env eq 'NONE'){
		$exepath=~/^mixmhc2\=(.*)/;
		$exepath = $1;
		if($exepath eq ''){
			print "\nPath for MixMHC2 is not set!";
			exit;
		}
		$exepath.='MixMHC2pred_unix';
	}else{
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

	
		$exepath = "conda run -n $conda_env MixMHC2pred_unix";
	}


my $hla;
if(open(FILE,"mhc2alleles.txt")){
	my @hlat = <FILE>;
	$hla= join(" ",@hlat);
	$hla=~s/\n//g;
}else{
	print "Couldn't open file $fname, $!"; exit;
}

`$exepath --input temp/12mer --no_context --alleles $hla  --output temp/MixMHC2`;
print "1";


