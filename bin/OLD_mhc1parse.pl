#! usr/bin/perl

open(FILE,"temp/9mer");
@pep=<FILE>;
close(FILE);

open(FILE,"temp/flurry");
@flurry=<FILE>;
close(FILE);
$FLURRY = join('',@flurry);

open(FILE,"temp/netmhci");
@netmhc=<FILE>;
close(FILE);
$NETMHC = join('',@netmhc);

$t = 'awk '."'".'{$3=sprintf("%.2f",$3)}1'."'".' temp/mhcseqnet >temp/TMHCSEQNET';
`$t`;

open(FILE,"temp/TMHCSEQNET");
@mhcseqnet=<FILE>;
close(FILE);
$SEQNET = join('',@mhcseqnet);

open(FILE,"temp/blast9");
@blast9=<FILE>;
close(FILE);
$BLAST9 = join('',@blast9);

open(FILE,"temp/nettepi");
@tcpas=<FILE>;
close(FILE);
$TCPAS = join('',@tcpas);

open(FILE,"temp/netctlpan");
@netctl=<FILE>;
close(FILE);
$NETCTL = join('',@netctl);

@HLA = ('HLA\-A\*01\:01', 'HLA\-A\*02\:01', 'HLA\-A\*02\:03', 'HLA\-A\*02\:06', 'HLA\-A\*03\:01', 'HLA\-A\*11\:01', 'HLA\-A\*23\:01', 'HLA\-A\*24\:02', 'HLA\-A\*26\:01', 'HLA\-A\*30\:01', 'HLA\-A\*30\:02', 'HLA\-A\*31\:01', 'HLA\-A\*32\:01', 'HLA\-A\*33\:01', 'HLA\-A\*68\:01', 'HLA\-A\*68\:02', 'HLA\-B\*07\:02', 'HLA\-B\*08\:01', 'HLA\-B\*15\:01', 'HLA\-B\*35\:01', 'HLA\-B\*40\:01', 'HLA\-B\*44\:02', 'HLA\-B\*44\:03', 'HLA\-B\*51\:01', 'HLA\-B\*53\:01', 'HLA\-B\*57\:01', 'HLA\-B\*58\:01');
$FP=$FW=$FS=$i0; $HLA_F='';

$finout="Position,Peptide,FlurryBinding,Flurry_HLA,NetMHCBinding,NET_MHC,SEQNET_Binding,SEQNET_HLA,Total_Unique_HLA,Population_Coverage,Fuzzy_BindingScore,BLAST_ProteinHitID,Fuzzy_BlastScore,Fuzzy_Tcell_Propensity,Fuzzy_TAPScore,Fuzzy_ClevageScore,Fuzzy_All_Score,Categoery_Score,Class\n";
foreach $x(@pep){
	$i++;
	$x=~s/\s//g;
	foreach $y (@HLA){
		if($FLURRY=~/$y\,$x\,(.*?)\,/){ #Binding
			$BAF = $1;
			if($BAF >800){
				$FP++;
			}elsif($BAF<400){
				$FW++;
				$HLA_F.=$y."(W);";

			}else{
				$FS++;
				$HLA_F.=$y."(S);";

			}

		}

		if($NETMHC=~/$y.*? $x.*? $x.*?[0-9](.*?)\n/){ #Binding

			$BAN = $1;
			#print $BAN;<STDIN>;
			if($BAN=~/\<\= WB/){
				$NW++;
				$HLA_N.=$y."(W);";
			}elsif($BAN=~/\<\= SB/){
				$NS++;
				$HLA_N.=$y."(S);";

			}else{
				$NP++;
			}

		}

		if($SEQNET=~/$x $y (.*?)\n/){ #Binding
			$BAS = $1;
			if($BAS <0.5){
				$SP++;
			}elsif($BAS<0.75){
				$SW++;
				$HLA_S.=$y."(W);";

			}else{
				$SS++;
				$HLA_S.=$y."(S);";

			}

		}
		$yy = $y;
		$yy=~s/\\*//g;
		if($TCPAS=~/$yy.*? $x(.*?)\n/){ #Tcell Propensity & Stability
			$TPS = $1;
			if($TPS=~/\<\=Epi/){
				$TPSCnt++;
			}
		}		
	}

	$Bid = $i.'\-'.($i+8);
	if($BLAST9=~/$Bid\,(.*?)\,.*?([0-9])\n/){ #BLAST 9
		$B1 = $1; $B2 = $2;
	}
	if($NETCTL=~/$x(.*?)\n/){ #TAP & CLEVAGE
		$Match_NTCL = $1;
		@Arr_NTCL = split(" ",$Match_NTCL);
	}

	#print "$FS,$FW,$FP\n";
	$HLA_F=~s/\\//g;
	$HLA_N=~s/\\//g;
	$HLA_S=~s/\\//g;
	$NRHLA = $HLA_F.$HLA_N.$HLA_S;
	$NRHLA=~s/\(W\)//g;
	$NRHLA=~s/\(S\)//g;
	@nrhla = split(";",$NRHLA);
	@unique = get_unique(@nrhla);
	$uniHLA = join(";",@unique);
	$POPuniHLA='';
	$POPuniHLA = join(",",@unique);
	
	if($POPuniHLA ne ''){
		open(FILE,">temp/pop");
		print FILE "EPITOPE\t".$POPuniHLA;
		close(FILE);
		`perl bin/iedbpop.pl`;
		open(FILE,"temp/popres");
		@POPR_F =<FILE>;
		close(FILE);
		$poptmp = join("",@POPR_F);
		$poptmp=~/World\t(.*?)\%/;
		$PC = $1;
		`rm temp/pop`;
		`rm temp/popres`;
		
	}else{
		$PC = 0;
		
	}
	
	#Fuzzy Calculation
	$Fuzz_Blast = ((100-($B2/9)*100));
	$Fuzz_Tcell = (($TPSCnt/13)*100);
	$Fuzz_TAP = ($Arr_NTCL[1]*100);
	$Fuzz_CLEV = ($Arr_NTCL[2]*100);
	$Fuzz_Binding = (((((($FS+($FW/2))/$FP)*100)+((($NS+($NW/2))/$NP)*100)+((($SS+($SW/2))/$SP)*100))/3)+$PC);


	$pr = `conda run -n OCTAVE octave bin/fuzzy.m $Fuzz_Blast $Fuzz_TAP $Fuzz_CLEV $Fuzz_Tcell $Fuzz_Binding`;
	#`clear`;
	#print "Fuzzy Processing for Peptide (".$i."/".@pep.")";
	#`clear`;
	$pr=~/(^[0-9].*)\n/g;
	$Fuzzy_OUT = $1;
	$CAT_SCORE = (($Fuzz_Binding/100)*($Fuzz_Tcell+$Fuzz_TAP+$Fuzz_Blast+$Fuzz_CLEV)*$Fuzzy_OUT);
	if($Fuzzy_OUT>=0.75){
		$Fuzz_Crisp = "Very High";
	}elsif($Fuzzy_OUT <0.25){
		$Fuzz_Crisp = "Low";
	}elsif($Fuzzy_OUT<=0.5){
		$Fuzz_Crisp = "Moderate";
	}else{
		$Fuzz_Crisp = "High";
	}
	#Fuzzy End
	$finout.= $i."-".($i+8).",".$x.",".(($FS+($FW/2))/$FP).",$HLA_F,".(($NS+($NW/2))/$NP).",$HLA_N,".(($SS+($SW/2))/$SP).",$HLA_S,$uniHLA,$PC,".(((((($FS+($FW/2))/$FP)*100)+((($NS+($NW/2))/$NP)*100)+((($SS+($SW/2))/$SP)*100))/3)+$PC).",$B1,".((100-($B2/9)*100)).",".(($TPSCnt/13)*100).",".($Arr_NTCL[1]*100).",".($Arr_NTCL[2]*100).",".$Fuzzy_OUT.",".$CAT_SCORE.",".$Fuzz_Crisp."\n";
	$FP=$FW=$FS=$NP=$NW=$NS=$SS=$SW=$SP=$TPSCnt=0; $HLA_F=$HLA_N=$HLA_S=$Fuzz_Blast=$Fuzz_Tcell=$Fuzz_TAP=$Fuzz_CLEV=$Fuxx_Binding=$pr=$Fuzzy_OUT=$Fuzz_Crisp=$CAT_SCORE='';undef @nrhla; undef @unique; undef @Arr_NTCL; $uniHLA=$NRHLA=$POPuniHLA=$B1=$B2='';

	
}
open(FILE,">temp/mhcifull.csv");
print FILE $finout;
close(FILE);

print "1";

sub get_unique {
    my %seen;
    grep !$seen{$_}++, @_;
}	
	

