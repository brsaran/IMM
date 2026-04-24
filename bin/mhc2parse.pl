#! usr/bin/perl

open(FILE,"temp/12mer");
@pep=<FILE>;
close(FILE);

open(FILE,"temp/netmhcii");
@netmhc=<FILE>;
close(FILE);
$NETMHC = join('',@netmhc);

open(FILE,"temp/MixMHC2");
@mixmhc=<FILE>;
close(FILE);
$MIXMHC = join('',@mixmhc);

open(FILE,"temp/blast12");
@blast12=<FILE>;
close(FILE);
$BLAST12 = join('',@blast12);


@HLA = ('DRB1\_0301', 'DRB1\_0701', 'DRB1\_1501', 'DRB3\_0101', 'DRB3\_0202', 'DRB4\_0101', 'DRB5\_0101');

$finout = "Position,Peptide,NetMHCII,NetMHCII_HLA,MixMHC2,MixMHC2_HLA,Unique_HLA,Average_Score,Protein_Hit,BLAST_Score,Final_category\n";
$FP=$FW=$FS=$i=$NW=$NS=$NP=0; $HLA_F='';

#$finout="Position,Peptide,FlurryBinding,Flurry_HLA,NetMHCBinding,NET_MHC,SEQNET_Binding,SEQNET_HLA,Total_Unique_HLA,Population_Coverage,Fuzzy_BindingScore,BLAST_ProteinHitID,Fuzzy_BlsatScore,Fuzzy_Tcell_Propensity,Fuzzy_TAPScore,Fuzzy_ClevageScore\n";
foreach $x(@pep){
	$i++;
	$x=~s/\s//g;
	foreach $y (@HLA){

		if($NETMHC=~/$y.*?$x.*?NA(.*?)\n/){ #Binding
			
			$BAN = $1;

			if($BAN=~/\<\=WB/){

				$NW++;
				$HLA_N.=$y."(W);";
			}elsif($BAN=~/\<\=SB/){
				$NS++;
				$HLA_N.=$y."(S);";

			}else{
				$NP++;
			}

		}

	}
	#BLAST12	
	$Bid = $i.'\-'.($i+11);

	if($BLAST12=~/$Bid\,(.*?)\,.*?([0-9])\n/){ #BLAST 9
		$B1 = $1; $B2 = $2;
	}
	if($MIXMHC=~/$x(.*?)\n/){
		#print $x."\n".$1."\n";<STDIN>;
		@Tmix = split("\t",$1);
#		print "$Tmix[7]\t$Tmix[10]\t$Tmix[13]\t$Tmix[16]\t$Tmix[19]\t$Tmix[22]\t$Tmix[25]";<STDIN>;

		if($Tmix[7]<5){$MixS++;$HLA_mix.="DRB1_0301(S);";}elsif($Tmix[7]<10){$MixW++;$HLA_mix.="DRB1_0301(W);";}else{$MixP++;}
		if($Tmix[10]<5){$MixS++;$HLA_mix.="DRB1_0701(S);";}elsif($Tmix[10]<10){$MixW++;$HLA_mix.="DRB1_0701(W);";}else{$MixP++;}
		if($Tmix[13]<5){$MixS++;$HLA_mix.="DRB1_1501(S);";}elsif($Tmix[13]<10){$MixW++;$HLA_mix.="DRB1_1501(W);";}else{$MixP++;}
		if($Tmix[16]<5){$MixS++;$HLA_mix.="DRB3_0101(S);";}elsif($Tmix[16]<10){$MixW++;$HLA_mix.="DRB3_0101(W);";}else{$MixP++;}
		if($Tmix[19]<5){$MixS++;$HLA_mix.="DRB3_0202(S);";}elsif($Tmix[19]<10){$MixW++;$HLA_mix.="DRB3_0202(W);";}else{$MixP++;}
		if($Tmix[22]<5){$MixS++;$HLA_mix.="DRB4_0101(S);";}elsif($Tmix[22]<10){$MixW++;$HLA_mix.="DRB4_0101(W);";}else{$MixP++;}
		if($Tmix[25]<5){$MixS++;$HLA_mix.="DRB5_0101(S);";}elsif($Tmix[25]<10){$MixW++;$HLA_mix.="DRB5_0101(W);";}else{$MixP++;}
		if($MixP==0){$MixP=1;}
	}

	$HLA_N=~s/\\//g;
	$WHLA = $HLA_N.$HLA_mix;
	if($NP==0){$NP=1;}
	if($MixP==0){$MixP=1;}
	$WHLA=~s/\(W\)//g;
	$WHLA=~s/\(S\)//g;
	@nrhla = split(";",$WHLA);
	@unique = get_unique(@nrhla);
	$uniHLA = join(";",@unique);
#	$POPuniHLA='';
#	$POPuniHLA = join(",",@unique);
	
#	if($POPuniHLA ne ''){
#		open(FILE,">temp/pop");
#		print FILE "EPITOPE\t".$POPuniHLA;
#		close(FILE);
		
#		`perl bin/iedbpop2.pl`;
#		open(FILE,"temp/popres");
#		@POPR_F =<FILE>;
#		close(FILE);
#		$poptmp = join("",@POPR_F);
#		$poptmp=~/World\t(.*?)\%/;
#		$PC = $1;
#		`rm temp/pop`;
#		`rm temp/popres`;
		
#	}else{
#		$PC = 0;
#		
#	}
	$MAverage = ((((($NS+($NW/2))/$NP)*100)+((($MixS+($MixW/2))/$MixP)*100))/2);
	$MBlast = ((100-($B2/12)*100));
	
	if($MAverage <= 8){ $Mcons = 0;}elsif($MAverage >=17){$Mcons = 1;}else{$Mcons = 0.5}
	if($MBlast <= 41){ $MBcons = 0;}elsif($MBlast >= 58){$MBcons = 1;}else{$MBcons = 0.5}

	if(($Mcons =="1") && ($MBcons) == "1"){ $fincat = "High";} elsif(($Mcons && $MBcons) == "0.5"){ $fincat = "Moderate";}elsif(($Mcons && $MBcons) == "0"){$fincat = "Low";}elsif(($Mcons || $MBcons) == "0"){$fincat = "Poor";}elsif(($Mcons || $MBcons) == "0.5"){$fincat ="Moderate";}
$finout.= $i."-".($i+11).",$x,".((($NS+($NW/2))/$NP)*100).",$HLA_N,". ((($MixS+($MixW/2))/$MixP)*100).",$HLA_mix,$uniHLA,".((((($NS+($NW/2))/$NP)*100)+((($MixS+($MixW/2))/$MixP)*100))/2).",$B1,".((100-($B2/12)*100)).",".$fincat."\n";
$NS=$NW=$NP=$MixS=$MixW=$MixP=0;$HLA_N=$HLA_mix='';undef @nrhla; undef @unique; undef @Tmix; $fincat=$Mcons=$MBcons=$uniHLA=$NRHLA=$POPuniHLA='';

}



open(FILE,">temp/mhciifull.csv");
print FILE $finout;
close(FILE);
print "1";

sub get_unique {
    my %seen;
    grep !$seen{$_}++, @_;
}	

	

