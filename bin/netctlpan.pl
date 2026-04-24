#! usr/bin/perl

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^netctlpan\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^netctlpan\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;


if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for NetCTLPan is not set!";
		exit;
	}
	$exepath.= 'netCTLpan';
	$run = "$exepath temp/fasta >temp/netctlpan";

}else{
	$exepath.= 'netCTLpan';
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}
	
	$run = "conda run -n $conda_env $exepath temp/fasta >temp/netctlpan";

}

`$run`;

print "1";


