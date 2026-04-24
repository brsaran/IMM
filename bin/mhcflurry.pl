#! usr/bin/perl

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^mhcflurry\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;

	if($conda_env eq 'NONE'){
		$exepath=~/^mhcflurry\=(.*)/;
		$exepath = $1;
		if($exepath eq ''){
			print "\nPath for MHCFLURRY is not set!";
			exit;
		}
		$exepath.='mhcflurry-predict';
	}else{
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

		$exepath = "conda run -n $conda_env mhcflurry-predict";
	}


my $hla;
if(open(FILE,"mhc1alleles.txt")){
	my @hlat = <FILE>;
	$hla= join(" ",@hlat);
	$hla=~s/\n//g;
}else{
	print "Couldn't open file $fname, $!"; exit;
}
if(open(PEP, "temp/9mer")){ 
	my @oriF = <PEP>;
	$pepS = join(" ",@oriF);
	$pepS=~s/\n//g;
	
}
else{ 
	print "Couldn't open file $fname, $!"; exit;
}

`$exepath --alleles $hla  --peptides $pepS --out temp/flurry `;
print "1";


