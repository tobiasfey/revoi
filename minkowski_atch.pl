#!/usr/bin/perl
# Erzeugen der Batch Datei für die Minkowski Berechungen

$file =$ARGV[0];
$startschicht = $ARGV[1];
$resolution = $ARGV[2];

open(CROP, "cropdir");
@CROP=();

use Cwd;
my $dir = getdcwd();

open(MINKBATCH, ">minkowski_batch.bat");


while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for(my $j =0;$j<$cropnumber;$j++){
	($sizex, $sizey, $xkorr, $ykorr) = $CROP[$j]=~/^(\d{2,4})x(\d{2,4})_x(\d{3})_y(\d{3})/;
	my $endeschicht = $startschicht + $sizey-1;
	my $anzahlx = $sizex / 10;
	my $anzahly = $sizey / 10;
	my $filenew = $CROP[$j] . "_" . $file;
	print MINKBATCH "cd $dir\\$CROP[$j]\\ \nperl U:\\Backup\\daten\\Programmierung\\Minkowski\\minkowski.pl 1 $filenew $startschicht $endeschicht 120 $anzahlx $anzahly 0 0 $resolution n\n";
}

print MINKBATCH "cd ..\n";

close(MINKBATCH);
