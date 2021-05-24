#!/usr/bin/perl
# Erzeugen einer Batch Datei für die KV Berechnung

$resolution=$ARGV[0];
$slice_diff = $ARGV[1];
$schichten = $ARGV[2];
$abstandschichten=$ARGV[3];

if(($resolution eq "") or ($slice_diff eq "") or ($schichten eq "" ) or ($abstandschichten eq "")){
	print "Resolution, Slice Diff, Schichten und Abstandschichten eingeben\n";
	exit;
}

open(CROP, "cropdir");
@CROP=();

use Cwd;
my $dir = getdcwd();

open(KVBATCH, ">kv_diff_${slice_diff}_${schichten}_${abstandschichten}_batch.bat");


while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for(my $j =0;$j<$cropnumber;$j++){
	print KVBATCH "cd $dir\\$CROP[$j]\\ \nperl U:\\Backup\\daten\\Programmierung\\Minkowski\\kv.pl $resolution $slice_diff $schichten $abstandschichten\n";
}

close(KVBATCH);
