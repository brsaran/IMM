#! usr/bin/perl

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^mhcseqnet\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^mhcseqnet\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for MHCseqNet is not set!";
		exit;
	}
	$pathmodel = $exepath.'PretrainedModels/one_hot_model/';
	$exepath.= 'MHCSeqNet.py';
	$run = 'python $exepath -p $pathmodel -m onehot -i complete temp/9mer mhc1alleles.txt temp/mhcseqnet';
}else{
	$pathmodel = $exepath.'PretrainedModels/one_hot_model/';
	$exepath .='MHCSeqNet.py';
	
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

	$run = "conda run -n $conda_env python ".$exepath." -p $pathmodel -m onehot -i complete temp/9mer mhc1alleles.txt temp/mhcseqnet";
}

`$run`;

print "1";

