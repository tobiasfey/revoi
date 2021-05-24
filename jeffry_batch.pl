#!/usr/bin/perl
# Erzeugen einer Batch Datei für die Jeffry Berechnung

open(CROP, "cropdir");
@CROP=();

use Cwd;
my $dir = getdcwd();

#$startschichtliste = $ARGV[0];
#$endschichtliste = $ARGV[1];

$schichten = $ARGV[0];
$abstandschichten=$ARGV[1];

if(($schichten == "" ) or ($abstandschichten =="")){
	print "Schichten und Abstandschichten eingeben\n";
	exit;
}

open(JEFFRYBATCH, ">jeffry_batch_${schichten}_${abstandschichten}.bat");


while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for(my $j =0;$j<$cropnumber;$j++){
	print JEFFRYBATCH "cd $dir\\$CROP[$j]\\ \nperl U:\\Backup\\daten\\Programmierung\\Minkowski\\jeffry.pl $schichten $abstandschichten\n";
}

close(JEFFRYBATCH);
