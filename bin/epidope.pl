#! usr/bin/perl

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^epidope\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;

	if($conda_env eq 'NONE'){
		$exepath=~/^epidope\=(.*)/;
		$exepath = $1;
		if($exepath eq ''){
			print "\nPath for epidope is not set!";
			exit;
		}
		$exepath.='epidope';
	}elsif($conda_env eq ''){
		print "\n Path/conda environment for epidope is not properly set!\n";
		exit;
	}
	else{
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

		$exepath = "conda run -n $conda_env epidope";
	}



`$exepath -i temp/fasta -l 12 -t 0.7 -o temp/epidope`;
print "1";


