#!/usr/bin/perl -w
# wird nicht direkt aufgerufen nur von KV_FIJI Batch.pl
# Erzeugung der Union zwischen den einzelnen schichten gemaess dem Paper von Ohser und Nagel 1996
use Cwd;

#($crop) = $dir =~ /\/(\w*)$/;
my $dir = getcwd;
print "Dir =$dir\n";
($crop) = $dir =~ /\/(\w*)$/;
print "Crop = $crop\n";

($sizex) = $crop =~ /^(\d{3,4})x\d{3,4}_/ ;
#($sizey) = $crop =~ /^\d{3,4}x(\d{3,4})_/ ;

# Einlesen der Bilder in eine Liste mit aufsteigender Zahlenfolge
@FILES=glob("*.ppm");
$filesnumber = $#FILES+1;

# Uebergabe der Parameter per ARGV
$slice_diff = $ARGV[0];
$schichten = $ARGV[1];
$abstandschichten=$ARGV[2];

if(($slice_diff eq "") or ($schichten eq "" ) or ($abstandschichten eq "")){
	print "Slice Diff, Schichten und Abstandschichten eingeben\n";
	exit;
}

print "Fiji Name = $crop\n";

#$m = sprintf("%d", $schichten / $sizex);
#print "m=$m\n";
$rest =( ($schichten-$sizex)/ $abstandschichten)+1;
# Aenderung 14.05.21
if($rest <1) {
	$rest = 1;
	print "Rest = $rest Grenzen korrigiert\n";
}
#print "rest =$rest\n";
open(MACRO, ">kv_${crop}_diff_${slice_diff}_${schichten}_${abstandschichten}.ijm");
	
for(my $p=0;$p<$rest;$p++){
		my $start = $p*$abstandschichten;
		# Aenderung 14.05.21
		if($rest == 1){
			$ende  = $schichten;
		}
		else{	
			$ende = $p*$abstandschichten + $sizex-1;
		}
		print "Start $start Ende $ende\n";
		
		open(PAIRS, ">${crop}_diff_${slice_diff}_liste_${start}_${ende}_pairs.txt");	
		# Schichten Anfang bis Ende von der Auswahl
		for (my $i =$start; $i<=$ende-$slice_diff; $i = $i+$slice_diff){
			
			#print "i = $i ";
			if ($i + $slice_diff < $filesnumber) {
				#print "filenumber $filesnumber\n";
				my ($slicenumber) =  $FILES[$i] =~ /_(\d{4}).ppm/;
				my $slicenumber_diff = $slicenumber + $slice_diff;
				$slicenumber_diff =sprintf("%04d",  $slicenumber_diff );		
				
				print PAIRS "$FILES[$i]\;$FILES[$i+$slice_diff]\n";
				# Batchmode
				print MACRO "setBatchMode(true)\;\n";
				print MACRO "open(\"${dir}/$FILES[$i]\")\;\n";
				print MACRO "open(\"${dir}/$FILES[$i+$slice_diff]\")\;\n";
				# Union
				print MACRO "imageCalculator(\"AND create\", \"$FILES[$i]\",\"$FILES[$i+$slice_diff]\")\;\n";
				print MACRO "selectWindow(\"Result of $FILES[$i]\")\;\n";
				print MACRO "run(\"8-bit\")\;\n";
				print MACRO "setThreshold(0,120)\;\n";
				print MACRO "setOption(\"BlackBackground\", false)\;\n";
				print MACRO "run(\"Convert to Mask\")\;\nrun(\"Watershed\")\;\n";
				print MACRO "run(\"Set Measurements...\", \"area perimeter fit feret's kurtosis redirect=None decimal=3\")\;\n";
				print MACRO "run(\"Analyze Particles...\", \"  show=Ellipses clear\")\;\n";
				print MACRO "saveAs(\"Results\", \"${dir}/${FILES[$i]}_union_${slicenumber_diff}_Results.csv\")\;\n";
				print MACRO "close()\;\n";
				print MACRO "selectWindow(\"Result of $FILES[$i]\")\;\n";
				print MACRO "close()\;\n";
				print MACRO "selectWindow(\"$FILES[$i]\")\;\n";
				print MACRO "close()\;\n";
				print MACRO "selectWindow(\"$FILES[$i+$slice_diff]\")\;\n";
				print MACRO "close()\;\n";	
			}
			else {
				print "Pairing ausserhalb der Range\n";
			}
			
		}
		
		close(PAIRS);
}

print MACRO "run(\"Quit\")\;\n";

close(MACRO);

