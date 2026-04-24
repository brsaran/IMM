#! usr/bin/perl

my $conda_env;
my $exepath;


	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^netmhcpanii\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^netmhcpanii\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;


my $hla;
	if(open(FILE,"mhc2allelesnet.txt")){
		my @hlat = <FILE>;
		$hla= join(",",@hlat);
		$hla=~s/\n//g;
		$hla=~s/\s//g;
		
	}else{
		print "Couldn't open file mhc2allelesnet\.txt, $!"; exit;
	}

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for netMHCpanII is not set!";
		exit;
	}
	$exepath.= 'netMHCIIpan';
	$run = "$exepath -f temp/fasta -a $hla -length 12 >temp/netmhcii";
	#print $run; <STDIN>;

}else{
	if($exepath eq ''){
		print "\nPath for netMHCpanII is not set!";
		exit;
	}
	$exepath.= 'netMHCIIpan';
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}
	
	$run = "conda run -n $conda_env $exepath -f temp/fasta -a $hla -length 12 >temp/netmhcii";

}

`$run`;

print "1";


