#!/usr/bin/perl

use Cwd;
use Math::Trig;
use Statistics::Basic qw(:all);
# Setzen auf 6 Nachkommastellen
$Statistics::Basic::IPRES = 6;

$pi=pi();


$schichten = $ARGV[0];
$abstandschichten=$ARGV[1];

if(($schichten == "" ) or ($abstandschichten =="")){
	print "Schichten und Abstandschichten eingeben\n";
	exit;
}

my $dir = getdcwd();
print "Dir =$dir\n";
($crop) = $dir =~ /\\(\w*)$/;
($sizex) = $crop =~ /^(\d{3,4})x\d{3,4}_/ ;
($sizey) = $crop =~ /^\d{3,4}x(\d{3,4})_/ ;
print ("h $sizex\n");
#Alles Schichten werden behandelt

@SCHICHTEN=glob("${crop}*ppm_Results.csv");


$counter=0;



$m = sprintf("%d", $schichten / $sizex);
$rest =( ($schichten-$sizex)/ $abstandschichten)+1;
# Aenderung 14.05.21
if($rest <1) {
	$rest = 1;
	$m=1;
	print "m = $m rest = $rest Grenzen korrigiert\n";
}

	
for(my $p=0;$p<$rest;$p++){
		my $start = $p*$abstandschichten;
		# Aenderung 14.05.21
		if($rest == 1){
			$ende  = $#SCHICHTEN;
		}
		else{		
			$ende = $p*$abstandschichten + $sizex-1;
		}	
		print "Start $start Ende $ende\n";
		my @PORENANZAHL_GESAMT =();
		my @POROSITAET_POREN_GESAMT=();
		my @JEFFRY_GESAMT = ();
		# Aenderung wg. steigender Schichten
		$counter = 0;
		$porenanzahl_gesamt  = 0;
		$porositaet_poren_gesamt = 0;
		$jeffry_gesamt = 0;
		
		open(OUT, ">${crop}_liste_${start}_${ende}_jeffry.txt");
		print OUT "Counter\tReale Schichtnummer\tPorenanzahl\tPorosiaet_pore\tArea_x\tArea_y\tm_v\tjeffry\n";
		
		for(my $m=$start ; $m<=$ende;$m++){
			#my $file=$_;
			#chomp $file;
			my $file =$SCHICHTEN[$m];
			#print "File = $file\n";
			$jeffry_file = $file;
			open(FILE, "$file");
	
			($schicht) = $file =~ /(\d{4}).ppm/ ;
	
			$flaeche_pixel_pore=0;
			$porenanzahl=0;
			while(<FILE>){
				my $zeile=$_;
				chomp $zeile;
				my $file=$zeile;
				my @ZEILE = split(/,/,$zeile);
				$flaeche_pixel_pore = $ZEILE[1]+$flaeche_pixel_pore;
				$porenanzahl = $ZEILE[0];			
			}	
			close(FILE);
			$counter++;
			$porositaet_poren = $flaeche_pixel_pore / ( $sizex*$sizey);
		
			$m_v = 2*$pi*$porenanzahl / ( $sizex*$sizey);
			$jeffry = sqrt((2*$pi*$porositaet_poren)/ $m_v);
		
			print OUT "$counter\t$schicht\t$porenanzahl\t$porositaet_poren\t$sizex\t$sizey\t$m_v\t$jeffry\n";
		
			$porenanzahl_gesamt = $porenanzahl_gesamt + $porenanzahl;
			$porositaet_poren_gesamt = $porositaet_poren_gesamt + $porositaet_poren ;
			$jeffry_gesamt = $jeffry_gesamt + $jeffry;
		
			push(@PORENANZAHL_GESAMT, $porenanzahl);
			push(@POROSITAET_POREN_GESAMT, $porositaet_poren);
			push(@JEFFRY_GESAMT, $jeffry);
		}

		close(OUT);
		
		# Probenname mit implementieren

		$jeffry_file =~ s/\d{4}.ppm_Results.csv/liste_${start}_${ende}_jeffry.txt/g;
		print "Jeffry File $jeffry_file\n";
		system("move ${crop}_liste_${start}_${ende}_jeffry.txt $jeffry_file");

		# Normierung ueber alle Schichten
		$norm_jeffry_file = "normiert_" . $jeffry_file;

		open(OUTNORM, ">$norm_jeffry_file");
		print OUTNORM ("Porenanzahl Gesamt\;Porositaet Poren Gesamt\;Jeffry Gesamt\;Anzahl Schichten\;Normierte Porenanzahl\;Normierte Porositaet\;Normierte Jeffry\;Mean Porenanzahl\;STDEV Porenanzahl\;Median Porenanzahl\;Mean Porositaet\;STDEV Porositaet\;Median Porositaet\;Mean Jeffry\;STDEV Jeffry\;Median Jeffry\n");
		$norm_porenanzahl_gesamt = $porenanzahl_gesamt  / $counter;
		$norm_porositaet_poren_gesamt  = $porositaet_poren_gesamt / $counter;
		$norm_jeffry_gesamt = $jeffry_gesamt / $counter;

		$mean_porenanzahl_gesamt = mean(@PORENANZAHL_GESAMT);
		$stddev_porenanzahl_gesamt = stddev(@PORENANZAHL_GESAMT);
		$median__porenanzahl_gesamt = median(@PORENANZAHL_GESAMT);

		$mean_porositaet_poren_gesamt = mean(@POROSITAET_POREN_GESAMT);
		$stddev_porositaet_poren_gesamt = stddev(@POROSITAET_POREN_GESAMT);
		$median__porositaet_poren_gesamt = median(@POROSITAET_POREN_GESAMT);

		$mean_jeffry_gesamt = mean(@JEFFRY_GESAMT);
		$stddev_jeffry_gesamt = stddev(@JEFFRY_GESAMT);
		$median__jeffry_gesamt = median(@JEFFRY_GESAMT);

		print OUTNORM ("$porenanzahl_gesamt\;$porositaet_poren_gesamt\;$jeffry_gesamt\;$counter\;$norm_porenanzahl_gesamt\;$norm_porositaet_poren_gesamt\;$norm_jeffry_gesamt\;$mean_porenanzahl_gesamt\;$stddev_porenanzahl_gesamt\;$median__porenanzahl_gesamt\;$mean_porositaet_poren_gesamt\;$stddev_porositaet_poren_gesamt\;$median__porositaet_poren_gesamt\;$mean_jeffry_gesamt\;$stddev_jeffry_gesamt\;$median__jeffry_gesamt\n");

		close(OUTNORM);
}
	





