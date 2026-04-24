#! usr/bin/perl

my $conda_env;
my $exepath;


	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^lbeep\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^lbeep\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for LBEEP is not set!\n";
		exit;
	}
	$exepath.= 'LBEEP4IMM';
	my $inPath = `pwd`;
	$inPath=~s/\s//g;
	$inFPath = $inPath."/temp/F12mer";
	$ouFPath = $inPath."/temp/lbeep";
	$run = "$exepath -i $inFPath -m pep -o $ouFPath";


}else{
	if($exepath eq ''){
		print "\nPath for LBEEP is not set!\n";
		exit;
	}
	$exepath.= 'LBEEP4IMM';
	my $inPath = `pwd`;
	$inPath=~s/\s//g;
	$inFPath = $inPath."/temp/F12mer";
	$ouFPath = $inPath."/temp/lbeep";
	$run = "$exepath -i $inFPath -m pep -o $ouFPath";
	`conda run -n $conda_env 2> err.txt`;
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}

	$run = "conda run -n $conda_env $exepath -i $inFPath -m pep -o $ouFPath";

}

`$run`;

print "1";


