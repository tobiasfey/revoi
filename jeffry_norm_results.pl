#!/usr/bin/perl
# Auswerten der jeffry norm Files nach Ausschnitt

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
	my @JEFFRYIN=glob("$CROP[$j]\\norm*list*jeffry.txt");
	#Aenderung einbauen
	foreach $file (@JEFFRYIN){
		#print ("Dfile = $file\n");
		(my $liste) = $file =~ /liste_(\d{1,5}_\d{1,5})/;
		open(JEFF, $file);
		while(<JEFF>){
			my $zeile =$_;
			chomp $zeile;
			$zeile =~ s/\./,/g;
			if($zeile =~ /^\d/){
				#print "$sizex, $sizey,$xkorr, $ykorr, $zeile\n";
				push(@JEFF, [$sizex, $sizey,$xkorr, $ykorr, $liste, $zeile]);
			}
		}
		close(JEFF);
	}
}
$jeffnumber = $#JEFF+1;

# Erstellen der Files pro x/y Ausschnitt
for(my $i=200;$i<700;$i=$i+100){
	open(JEFFSUM, ">jeff_norm_sum_${i}x${i}.csv");
	print JEFFSUM ("Ausschnitt\;Bereich\;Liste\;Porenanzahl Gesamt\;Porositaet Poren Gesamt\;Jeffry Gesamt\;Anzahl Schichten\;Normierte Porenanzahl\;Normierte Porositaet\;Normierte Jeffry\;Mean Porenanzahl\;STDEV Porenanzahl\;Median Porenanzahl\;Mean Porositaet\;STDEV Porositaet\;Median Porositaet\;Mean Jeffry\;STDEV Jeffry\;Median Jeffry\n");
	for(my $k=0;$k<$jeffnumber;$k++){
		if($JEFF[$k][0] == $i){
			print JEFFSUM "${JEFF[$k][0]}x${JEFF[$k][1]}\;x${JEFF[$k][2]}_y${JEFF[$k][3]}\;$JEFF[$k][4]\;$JEFF[$k][5]\n";
		}
	}
	close(JEFFSUM);
}
