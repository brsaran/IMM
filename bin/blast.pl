#!usr/bin/perl
#`blastp -query fasta -word_size 2 -db HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out refIED -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2`;


open(FILE,"temp/9mer");
@F9cont = <FILE>;
close(FILE);

open(FILE,"temp/12mer");
@F12cont = <FILE>;
close(FILE);

#open(FILE,"temp/15mer");
#@F15cont = <FILE>;
#close(FILE);

my $cnt = 1;
open(FILE,">temp/F9mer");
foreach my $x(@F9cont){
	print FILE ">".$cnt."-".($cnt+8)."\n".$x;
	$cnt++;
}
$cnt=1;
close(FILE);
open(FILE,">temp/F12mer");
foreach my $x(@F12cont){
	print FILE ">".$cnt."-".($cnt+11)."\n".$x;
	$cnt++;
}
$cnt=1;
close(FILE);

#open(FILE,">temp/F15mer");
#foreach my $x(@F15cont){
#	print FILE ">".$cnt."-".($cnt+14)."\n".$x;
#	$cnt++;
#}
#$cnt=1;
#close(FILE);

my $conda_env;
my $exepath;

	open(FILE,"path");
	my @path = <FILE>;
	close(FILE);
	
	for(my $i=0;$i<@path;$i++){
		if($path[$i]=~m/^blast\=/){
			$exepath = $path[$i];
			$conda_env = $path[$i+1];
		}
		
	}
	$conda_env=~/^conda_env\=(.*)/;
	$conda_env = $1;
	$conda_env =~s/\s//g;
	$exepath=~/^blast\=(.*)/;
	$exepath = $1;
	$exepath=~s/\s//g;

if($conda_env eq 'NONE'){
	if($exepath eq ''){
		print "\nPath for BLAST is not set!";
		exit;
	}
	$exepath.= 'blastp';
	$run9 = $exepath.' -query temp/F9mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b9 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
	$run12 = $exepath.' -query temp/F12mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b12 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
#	$run15 = $exepath.' -query temp/F15mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b15 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
}else{
	`conda run -n $conda_env 2> err.txt`;
	unless (-e "err.txt"){print "\nEnvironment $conda_env does not exist!\n"; `rm err.txt`; exit;}


	$exepath .='blastp';
	$run9 = "conda run -n $conda_env ".$exepath.' -query temp/F9mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b9 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
	$run12 = "conda run -n $conda_env ".$exepath.' -query temp/F12mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b12 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
#	$run15 = "conda run -n $conda_env ".$exepath.' -query temp/F15mer -word_size 2 -db blast_bin/HUMAN -matrix PAM30 -outfmt "10 delim=, qacc sacc qseq sseq" -out temp/b15 -max_target_seqs 1 -evalue 50 -gapopen 7 -gapextend 2';
}

`$run9`;
`$run12`;
#`$run15`;

&blast_verify('temp/b9','temp/blast9','9');
&blast_verify('temp/b12','temp/blast12','12');
#&blast_verify('temp/b15','temp/blast15','15');

print "1";


sub blast_verify{
	my $seqCo = $_[0]; #file
	my $seqNa = $_[1]; #outfile
	my $seqLe = $_[2]; #length
	
	open(FILE,"$seqCo");
	my @Acont = <FILE>;
	close(FILE);
	my $cnt = 1;

	foreach my $x(@Acont){
		my @tarr = split(",",$x);
		my $veri = $cnt.'-'.$seqLe;
#		print $tarr[0]."\t".$veri;<STDIN>;
		$tarr[1]=~/\|(.*)\|/;		
		my $Uid = $1;
		my $ou,$Fou;
		if($tarr[0] eq $veri){
			$ou = $tarr[0].",".$Uid.",".$tarr[2].",".$tarr[3].",".&match($tarr[2],$tarr[3]);
			$ou=~s/\n//g;
			$Fou.= $ou."\n";
		}else{
			$tarr[0]=~/(.*)\-/;
			my $start = $1;
			for(my $y=$cnt;$y<$start;$y++){
				$Fou.= $y."-".$seqLe.",Nohit,Nohit,Nohit,0\n";
				$cnt++;
				$seqLe++;	
			}			
			$ou = $tarr[0].",".$Uid.",".$tarr[2].",".$tarr[3].",".&match($tarr[2],$tarr[3]);
			$ou=~s/\n//g;
			$Fou.= $ou."\n";

		}
		$cnt++;
		$seqLe++;		
	}
	open(FILE,">$seqNa");
	print FILE $Fou;
	close(FILE);
	$Fou="";

	return 0;
}
sub match(){
	$e = $_[0];
	$f = $_[1];
	$max=$cont="";
	if($e eq $f){
		return length($e);
	}else{
		@earr = split("",$e);
		@farr = split("",$f);
		for($z=0;$z<@earr;$z++){

			if($earr[$z] eq $farr[$z]){
				$cont++;
			}else{
				if($cont > $max){
					$max = $cont;
					$cont ="";
				}else{
					$cont= "";
				}
			}
		}
		if($cont > $max){
			$max = $cont;
			$cont ="";
		}
		
	}
	return $max;
}
