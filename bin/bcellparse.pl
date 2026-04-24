#! usr/bin/perl

open(FILE,"temp/12mer");
@pep=<FILE>;
close(FILE);

open(FILE,"temp/blast12");
@blast12=<FILE>;
close(FILE);
$BLAST12 = join('',@blast12);

open(FILE,"temp/lbeep");
@Flbeep=<FILE>;
close(FILE);
$LBEEP = join('',@Flbeep);

open(FILE,"temp/epidope/predicted_epitopes_sliced.faa");
@FEpidope=<FILE>;
close(FILE);
$EPIDOPE = join('',@FEpidope);

$finout = "Position,Peptide,Lbeep,Epidope,Consensus,Protein_Hit,BLAST_Score,Category\n";



foreach $x(@pep){
	$i++;
	$x=~s/\s//g;

	#LBEEP
	if($LBEEP=~/$x\|\,(.*?)\n/){	
		$S_Lbeep = $1;
	}
	#EPIDOPE
	if($EPIDOPE=~/$x/){	
		$S_epidope = "0.7";
	}else{
		$S_epidope = "0";
	}

	#BLAST12	
	$Bid = $i.'\-'.($i+11);

	if($BLAST12=~/$Bid\,(.*?)\,.*?([0-9])\n/){ #BLAST 9
		$B1 = $1; $B2 = $2;
	}
	#Final Cat
	if($S_Lbeep >= 0.6){
		if($S_epidope >=0.7){
			$cat = "S";
		}else{
			$cat = "W";
		}
	}else{
		if($S_epidope >=0.7){
			$cat = "W";
		}else{
			$cat = "P";
		}
	}		
		
	$Bcat = ((100-($B2/12)*100));

	if($Bcat >= 50){

		if($cat eq 'S'){
			$Fcat = "High";
		}elsif($cat eq 'W'){
			$Fcat = 'Moderate';
		}elsif($cat eq'P'){
			$Fcat = 'Low';
		}

	}elsif($Bcat < 33){
		if($cat eq 'S'){
			$Fcat = "Moderate";
		}elsif($cat eq 'W'){
			$Fcat = 'Low';
		}elsif($cat =='P'){
			$Fcat = 'Low';
		}
	}else{
		if($cat eq 'S'){
			$Fcat = "Moderate";
		}elsif($cat eq 'W'){
			$Fcat = 'Moderate';
		}elsif($cat eq 'P'){
			$Fcat = 'Low';
		}
	}

$finout.= $i."-".($i+11).",$x,$S_Lbeep,$S_epidope,$cat,$B1,".((100-($B2/12)*100)).",".$Fcat."\n";
$S_Lbeep=$S_epidope=$B1=$B2=$cat=$Fcat=$Bcat="";

}



open(FILE,">temp/bcellfull.csv");
print FILE $finout;
close(FILE);

print "1";


