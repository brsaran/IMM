#! usr/bin/perl


my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^nettepi\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^nettepi\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;


my $hla;
	if(open(FILE,"mhc1nettepi.txt")){
		my @hlat = <FILE>;
		$hla= join(",",@hlat);
		$hla=~s/\n//g;
		$hla=~s/\*//g;
	}else{
		print "Couldn't open file mmhc1nettepi\.txt, $!"; exit;
	}
close(FILE);

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for NetTepi is not set!";
		exit;
	}
	$exepath.= 'netTepi';
	$run = "$exepath temp/fasta >temp/nettepi -a $hla -l 9";

}else{
	$exepath.= 'netTepi';
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}
	
	$run = "conda run -n $conda_env $exepath temp/fasta >temp/nettepi -a $hla -l 9";

}

`$run`;

print "1";


