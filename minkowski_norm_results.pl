#!/usr/bin/perl 
#Auslesen der Daten aus den Minkowskifiles und Normieren.
use Cwd;
use Math::Trig;

use Statistics::Basic qw(:all);
# Setzen auf 6 Nachkommastellen
$Statistics::Basic::IPRES = 6;
$sample=$ARGV[0];

open(CROP, "cropdir") or die ("Datei cropdir nicht gefunden\n");
@CROP=();

use Cwd;
my $dir = getdcwd();

while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;




for(my $j =0;$j<$cropnumber;$j++){
	($sizex, $sizey, $xkorr, $ykorr) = $CROP[$j]=~/^(\d{2,4})x(\d{2,4})_x(\d{3})_y(\d{3})/;
	#@FILES=();
	open(IN, "dir /b $CROP[$j]\\*statistik.txt |");
	
	while(<IN>){
		my $file=$_;
		chomp $file;
		print "Files = $file\n";
		push(@FILES, $file);
		}
	}
	close(IN);
	

close(OUT);

# Auswertung der Dateien 

$number = $#FILES+1;
@RESULT =();

open(RESULT, ">result_minkowski_$sample");
for(my $i = 0; $i<$number; $i++){
	
	my $file = $FILES[$i];
	($crop, $size) = $file =~ /^((\d{2,4})x\d{2,4}_x\d{3}_y\d{3})/;
	#print "$size, $crop, $file\n";
	
	open(IN, "${crop}\\$FILES[$i]");
	
	while(<IN>){
		my $zeile = $_;
		chomp $zeile;
		if($zeile =~ /L_quer_x/){
		}
		else{
		
		$zeile =~ s/\,/\./g;
		my @LISTE = split(/\;/, $zeile);
		push(@RESULT, [$size, $crop, $LISTE[0], $LISTE[1], $LISTE[2], $LISTE[3], $LISTE[4], $LISTE[5]]);
		print RESULT "$crop\;$size\;$LISTE[0]\;$LISTE[1]\;$LISTE[2]\;$LISTE[3]\;$LISTE[4]\;$LISTE[5]\n";
		}
	}
	close (IN);
	
	
	
}
close(RESULT);

sub normalize {

	$resultnumber = $#RESULT+1;
	open(RESULTNORM, ">result_norm_minkowski_$sample");
	print RESULTNORM "Size\;Mean SV_X\;STDDEV SV_X\;Mean SV_Y\;STDDEV SV_Y\;Mean L_quer_x\;STDDEV L_quer_X\;Mean L_quer_y\;STDDEV L_quer_y\;Mean Area\n";

	# Normalisierung
	for(my $m = 200;$m<700;$m=$m+100){
		@SVX=();
		@SVY=();
		@LQUERX=();
		@LQUERY=();
		@AREA=();
		
		for(my $p =0; $p<$resultnumber;$p++){
			
			if($RESULT[$p][0] == $m){
				push(@SVX, $RESULT[$p][3]);
				push(@SVY, $RESULT[$p][4]);
				push(@LQUERX, $RESULT[$p][5]);
				push(@LQUERY, $RESULT[$p][6]);
				push(@AREA, $RESULT[$p][7]);
			}
		
		}
		print "Auswertung\n";
		$svnormx = mean(@SVX);
		$svnormxdev = stddev(@SVX);
		$svnormy = mean(@SVY);
		$svnormydev = stddev(@SVY);
		$lquernormx = mean(@LQUERX);
		$lquernormxdev = stddev(@LQUERX);
		$lquernormy = mean(@LQUERY);
		$lquernormydev = stddev(@LQUERY);
		
		$areanorm = mean(@AREA);
		$areanormdev = stddev(@AREA);
		my $printstring = $m."\;".$svnormx."\;".$svnormxdev."\;".$svnormy."\;".$svnormydev."\;".$lquernormx."\;".$lquernormxdev."\;".$lquernormy."\;".$lquernormydev."\;".$areanorm."\;".$areanormdev;
		$printstring =~ s/\,//g;
		$printstring =~ s/\./\,/g;
		print RESULTNORM "$printstring\n";
		#print RESULTNORM "$m\;$svnormx\;$svnormxdev\;$svnormy\;$svnormydev\;$lquernormx\;$lquernormxdev\;$lquernormy\;$lquernormydev\;$areanorm\;$areanormdev\n";
	}
		
	close(RESULTNORM);
}

&normalize;