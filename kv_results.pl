#!/usr/bin/perl
# Auswerten der KV SUM Files nach Ausschnitt
$slice_diff = $ARGV[0];

if($slice_diff eq ""){
	print "Slice Diff eingeben\n";
	exit;
}

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
	my @KVIN= glob("$CROP[$j]\\kv_sum_*diff*list*.txt");
	#Aenderung einbauen
	foreach $file (@KVIN){
		#print ("Dfile = $file\n");
		(my $liste) = $file =~ /liste_(\d{1,5}_\d{1,5})/;
		open(SUMDATA, $file);
		
		while(<SUMDATA>){
			my $zeile =$_;
			chomp $zeile;
			$zeile =~ s/\./,/g;
			if($zeile =~ /^\d/){
				($v,$w_i,$x,$x_v,$resolution) = split(/\;/, $zeile);
				print " $sizex, $sizey, $xkorr, $ykorr, $v,$w_i,$x,$x_v,$resolution\n";
				push(@KV, [$sizex, $sizey,$xkorr, $ykorr, $liste, $v,$w_i,$x,$x_v,$resolution]);
			}
		}
		
		close(SUMDATA);
	}
}
$kvnumber = $#KV+1;

# Erstellen der Files pro x/y Ausschnitt
for(my $i=200;$i<700;$i=$i+100){
	open(KVSUM, ">kv_sum_${slice_diff}_${i}x${i}.csv");
	print KVSUM "Dim x \: Dim y\;X korr _ Y korr\;Liste\;Volume (mm3)\;Flaeche (mm2)\;X\;X_V (mm-3)\n";
	#for(my $k=0;$k<$cropnumber;$k++){
		for(my $k = 0; $k<$kvnumber;$k++){
			print "i = $i KV $KV[$k][0]\n";
			if($KV[$k][0] == $i){
				print KVSUM "${KV[$k][0]}x${KV[$k][1]}\;x${KV[$k][2]}_y${KV[$k][3]}\;$KV[$k][4]\;$KV[$k][5]\;$KV[$k][6]\;$KV[$k][7]\;$KV[$k][8]\n";
			}
		#}
		}	
	close(KVSUM);
}