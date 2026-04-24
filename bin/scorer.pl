#! usr/bin/perl

open(FILE,"temp/fasta");
@FAS=<FILE>;
close(FILE);

$FAS[0]='';
$fasta = join('',@FAS);
undef(@FAS);
$fasta =~s/\s//g;


open(FILE,"temp/mhcifull.csv");
@M1=<FILE>;
close(FILE);

open(FILE,"temp/mhciifull.csv");
@M2=<FILE>;
close(FILE);


open(FILE,"temp/bcellfull.csv");
@Bc=<FILE>;
close(FILE);

$r1 = @M1;
$r1 = ($r1-1)+8;
$r1 = $r1-32;

$out = "Postion,M1-M2-B,M1-B-M2,M2-B-M1,M2-M1-B,B-M2-M1,B-M1-M2\n";
$html = '<pre><table><tr><td bgcolor="#FFFF99">Color Key:</td><td>Two moderate or one moderate and one high;</td><td bgcolor="#00CC33">Color Key:</td><td>Two high</tr></table></td><table style ="font-size:80%;" border="2" style="background-color:#FFFFFF;border-collapse:collapse;border:2px solid #000000;color:#000000;width:100%" cellpadding="3" cellspacing="3">'.'<tr><td><b>Position</td><td><b>Sequence</td><td><b>M1-M2-B</td><td><b>M1-B-M2</td><td><b>M2-B-M1</td><td><b>M2-M1-B</td><td><b>B-M2-M1</td><td><b>B-M1-M2</td></b></tr>';
for($i=1;$i<=$r1;$i++){
	@temp1 = split(",",$M1[$i]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i+9]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i+9+12]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $i."-".($i+32).",".$MHC1."-".$MHC2."-".$Bcell.";".($i)."-".($i+8).";".($i+9)."-".($i+9+11).";".($i+9+12)."-".($i+9+12+11).",";
	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else{$ccol = "#FFFF99";}
	$html.= '<tr><td>'.$i."-".($i+32).'</td><td>'.substr($fasta,($i-1),33).'</td><td bgcolor="'.$ccol.'">'.$MHC1."-".$MHC2."-".$Bcell.";".($i)."-".($i+8).";".($i+9)."-".($i+9+11).";".($i+9+12)."-".($i+9+12+11).'</td>';

	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';

	@temp1 = split(",",$M1[$i]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i+9+12]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i+9]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $MHC1."-".$Bcell."-".$MHC2.";".($i)."-".($i+8).";".($i+9)."-".($i+9+11).";".($i+9+12)."-".($i+9+12+11).",";
	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else {$ccol = "#FFFF99";}
	$html.= '<td bgcolor="'.$ccol.'">'.$MHC1."-".$Bcell."-".$MHC2.";".($i)."-".($i+8).";".($i+9)."-".($i+9+11).";".($i+9+12)."-".($i+9+12+11).'</td>';

	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';


	@temp1 = split(",",$M1[$i+12+12]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i+12]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $MHC2."-".$Bcell."-".$MHC1.";".($i)."-".($i+11).";".($i+12)."-".($i+12+11).";".($i+12+12)."-".($i+12+12+8).",";
	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else {$ccol = "#FFFF99";}
	$html.= '<td bgcolor="'.$ccol.'">'.$MHC2."-".$Bcell."-".$MHC1.";".($i)."-".($i+11).";".($i+12)."-".($i+12+11).";".($i+12+12)."-".($i+12+12+8).'</td>';

	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';

	@temp1 = split(",",$M1[$i+12]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i+12+9]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $MHC2."-".$MHC1."-".$Bcell.";".($i)."-".($i+11).";".($i+12)."-".($i+12+8).";".($i+12+9)."-".($i+12+9+11).",";

	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else {$ccol = "#FFFF99";}
	$html.= '<td bgcolor="'.$ccol.'">'.$MHC2."-".$MHC1."-".$Bcell.";".($i)."-".($i+11).";".($i+12)."-".($i+12+8).";".($i+12+9)."-".($i+12+9+11).'</td>';

	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';


	@temp1 = split(",",$M1[$i+12+12]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i+12]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $Bcell."-".$MHC2."-".$MHC1.";".($i)."-".($i+11).";".($i+12)."-".($i+12+11).";".($i+12+12)."-".($i+12+12+8).",";

	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else {$ccol = "#FFFF99";}
	$html.= '<td bgcolor="'.$ccol.'">'.$Bcell."-".$MHC2."-".$MHC1.";".($i)."-".($i+11).";".($i+12)."-".($i+12+11).";".($i+12+12)."-".($i+12+12+8).'</td>';

	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';


	@temp1 = split(",",$M1[$i+12]);
	$MHC1 = $temp1[-1];
	$MHC1=~s/\s//g;
	
	@temp2 = split(",",$M2[$i+9+12]);
	$MHC2 = $temp2[-1];
	$MHC2=~s/\s//g;

	@temp3 = split(",",$Bc[$i]);
	$Bcell = $temp3[-1];
	$Bcell=~s/\s//g;

	$out.= $Bcell."-".$MHC1."-".$MHC2.";".($i)."-".($i+11).";".($i+12)."-".($i+12+8).";".($i+12+9)."-".($i+12+9+11)."\n";
	$color  = $MHC1.$MHC2.$Bcell;
	$Lcount = ($color=~tr/L/L/);
	$Hcount = ($color=~tr/H/H/);
	if($Lcount >= 2){$ccol = "#FFFFFF";}elsif($Hcount >=2){$ccol = "#00CC33";}else {$ccol = "#FFFF99";}
	$html.= '<td bgcolor="'.$ccol.'">'.$Bcell."-".$MHC1."-".$MHC2.";".($i)."-".($i+11).";".($i+12)."-".($i+12+8).";".($i+12+9)."-".($i+12+9+11).'</td></tr>';


	undef(@temp1);
	undef(@temp2);
	undef(@temp3);
	$MHC1=$MHC2=$Bcell=$color=$Lcount=$Hcount=$ccol='';
}

$html.='</table></font></pre>';

open(FILE,">temp/result.csv");
print FILE $out;
close(FILE);

open(FILE,">temp/result.html");
print FILE $html;
close(FILE);

print "1";


