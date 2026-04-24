#! usr/bin/perl

my $conda_env;
my $exepath;


	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^netmhcpani\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^netmhcpani\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;


my $hla;
	if(open(FILE,"mhc1alleles.txt")){
		my @hlat = <FILE>;
		$hla= join(",",@hlat);
		$hla=~s/\n//g;
		$hla=~s/\*//g;
	}else{
		print "Couldn't open file mhc1alleles\.txt, $!"; exit;
	}

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for netMHCpan is not set!";
		exit;
	}
	$exepath.= 'netMHCpan';
	$run = "$exepath temp/fasta >temp/netmhci -a $hla -l 9";

}else{
	$exepath.= 'netMHCpan';
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

	$run = "conda run -n $conda_env $exepath temp/fasta >temp/netmhci -a $hla -l 9";

}

`$run`;

print "1";


