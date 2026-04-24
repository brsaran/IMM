#! usr/bin/perl

my $conda_env;
my $exepath;


	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^IEDBpop\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^IEDBpop\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;



if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for IEDB population tool is not set!";
		exit;
	}
	$exepath.= 'calculate_population_coverage.py';
	$run = "python $exepath -p World -c I -f temp/pop >temp/popres";
	#print $run; <STDIN>;

}else{
	if($exepath eq ''){
		print "\nPath for IEDB population tool is not set!";
		exit;
	}
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

	
	$exepath.= 'calculate_population_coverage.py';
	$run = "conda run -n $conda_env python $exepath -p World -c I -f temp/pop >temp/popres";

}

`$run`;

print "1";


