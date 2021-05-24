#!/usr/bin/perl

use Cwd;
use Statistics::Basic qw(:all);
# Aufloesung in µm
$resolution = $ARGV[0];
$slice_diff = $ARGV[1];
$resolution = $resolution / 1000;
$schichten = $ARGV[2];
$abstandschichten=$ARGV[3];


my $dir = getdcwd();
# print ($dir);
($crop) = $dir =~ /\\(\w*)$/;
($sizex, $sizey) = $crop =~/^(\d{2,4})x(\d{2,4})/;
print "Size = $sizex $sizey\n";


#$m = sprintf("%d", $schichten / $sizex);
#print "m=$m\n";
$rest =( ($schichten-$sizex)/ $abstandschichten)+1;
#print "rest =$rest\n";
# Aenderung 14.05.21
if($rest <1) {
	$rest = 1;
	print "Rest = $rest Grenzen korrigiert\n";
}



#print  $PAIRS[0][0] , $PAIRS[0][1] ;
#$firstslice) = $PAIRS[0][0] =~ /(\d{4}).ppm/;
#($lastslice) = $PAIRS[-1][1] =~ /(\d{4}).ppm/;
#$schichtanzahl =$lastslice  - $firstslice;
#print "Schichten = $schichtanzahl\n";	
# Aendert sich da nur immer die gleichen Volumina betrachtet werden

for(my $p=0;$p<$rest;$p++){
		my $start = $p*$abstandschichten;
		# Aenderung 14.05.21
		if($rest == 1){
			$ende  = $schichten;
		}
		else{		
			$ende = $p*$abstandschichten + $sizex-1;
		}	
		#my $ende = $p*$abstandschichten + $sizex-1;
		print "Start $start Ende $ende\n";
		
		#Schichtanzahl der SChichten innerhalb des betrachteten Volumens
		$schichtanzahl = ($ende -$start) +1;
		# Schleife zum Öffnen der Dateien
		@PAIRS=();
		@XNUMBERS =();
		# Einlesen aller Paarungen
		open(PAIRS, "${crop}_diff_${slice_diff}_liste_${start}_${ende}_pairs.txt");

		while(<PAIRS>){
			my $zeile = $_;
			chomp $zeile;
			#print "$zeile\n";
			push(@PAIRS, [split(/;/, $zeile)]);
		}
		close(PAIRS);

		open(DATAOUT, ">kv_data_${crop}_diff_${slice_diff}_liste_${start}_${ende}.txt");

		$pairsnumber = $#PAIRS +1;
		
		
		#Start und Ende gemessen an den Schichten, muss aber dann noch auf den Abstand fuer das Pairing angepasst werden
		
		#for(my $m=$start ; $m<=$ende;$m++){
		for(my $i =0; $i<$pairsnumber;$i++){
			# Oeffnen des urspruenglischen Slices
			open(SLICE, "$PAIRS[$i][0]_Results.csv") or die ("Slice File nicht gefunden");
			
			my ($partnerslice) = $PAIRS[$i][1] =~ /(\d{4}).ppm/;
			my ($slice) =  $PAIRS[$i][0] =~ /(\d{4}).ppm/;
			my $difference = $partnerslice - $slice;
			#Oeffnen des Union Files
			open(UNION, "$PAIRS[$i][0]_union_${partnerslice}_Results.csv") or die ("Union File $PAIRS[$i][0]_union_${partnerslice}_Results.csv nicht gefunden");
			
			
			#Auslesen der Files
			# Slice
			$porenanzahl_slice=0;
			while(<SLICE>){
				my $zeile=$_;
				chomp $zeile;
				my @ZEILE = split(/,/,$zeile);
				#$flaeche_pixel_pore = $ZEILE[1]+$flaeche_pixel_pore;
				$porenanzahl_slice = $ZEILE[0];	
			}
			close(SLICE);
			
			$porenanzahl_union=0;
			while(<UNION>){
				my $zeile=$_;
				chomp $zeile;
				my @ZEILE = split(/,/,$zeile);
				#$flaeche_pixel_pore = $ZEILE[1]+$flaeche_pixel_pore;
				$porenanzahl_union= $ZEILE[0];	
			}
			close(UNION);
			
			push(@XNUMBERS, [$start, $ende, $slice, $partnerslice, $porenanzahl_slice, $porenanzahl_union]);
			
		}



		$xnumbers = $#XNUMBERS+1;

		# Teil 1 start von i=2 bis n 
		# Y(i-1) union Y(i) - Y(i-1)
		$teil1=0;
		# Teil 2 start von i=1 bis n-1 
		# Y(i) union Y(i+1) - Y(i+1)
		$teil2=0;
		for(my $i =0; $i< $xnumbers; $i++){
			# Achtung start mit 0 in der Formel mit 1 fuer i
			# Berechnung X
			
			if($i >0) {		
				$teil1 = $XNUMBERS[$i][5]-$XNUMBERS[$i-1][4];
				#print "U $XNUMBERS[$i][5] S $XNUMBERS[$i-1][4] $teil1\n";
			}
			else{
				$teil1 = 0;
				}
			
			if($i<$xnumbers-1){
				$teil2 = $XNUMBERS[$i+1][5]-$XNUMBERS[$i+1][4];
				#print "$teil2\n";
			}
			else {
				$teil2=0;
				}
			print DATAOUT "$i\;$XNUMBERS[$i][4]\;$XNUMBERS[$i][5]\;$teil1\;$teil2\n";
			# Summenbildung
			$teil1sum = $teil1sum + $teil1;
			$teil2sum = $teil2sum + $teil2;
			#$schicht = $i +1;
		}

			
		close(DATAOUT);

		# X fuer alle Slices
		$x = 0.5*($teil1sum+$teil2sum);

		# Flaeche
		$w_i = $sizex * $sizey * $resolution * $resolution;
		
		#Volumen
		$v =$w_i*$resolution *$schichtanzahl;
		#X_V Volumen
		$x_v= $x/$v;

		print "wi = $w_i $v $schichtanzahl $resolution\n";
		
		open(SUMDATA, ">kv_sum_${crop}_diff_${slice_diff}_liste_${start}_${ende}.txt");
		print SUMDATA "Volume (mm3)\;Flaeche (mm2)\;X\;X_V (mm-3)\n";
		print SUMDATA "$v\;$w_i\;$x\;$x_v\;$resolution\n";
		close(SUMDATA);
		
	}

