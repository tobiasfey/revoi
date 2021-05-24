#!/usr/bin/perl
# Erzeugen der Fiji-Macros fuer eine ganze Serie und einer Batch Datei für FiJi
# Zur Berechnung der KV_Daten mit Union und Intersection


open(CROP, "cropdir") or die ("Datei cropdir nicht gefunden\n");
@CROP=();

# Uebergabe der Parameter per ARGV
$slice_diff = $ARGV[0];
$schichten = $ARGV[1];
$abstandschichten=$ARGV[2];

if(($slice_diff eq "") or ($schichten eq "" ) or ($abstandschichten eq "")){
	print "Slice Diff, Schichten und Abstandschichten eingeben\n";
	exit;
}

use Cwd;
my $dir = getdcwd();

open(KVFIJIBATCH, ">kv_fiji_diff_${slice_diff}_macro_batch_${schichten}_${abstandschichten}.bat");
open(KVFIJIMACRO, ">kv_fiji_diff_${slice_diff}_macro_create_${schichten}_${abstandschichten}.bat");

while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for(my $j =0;$j<$cropnumber;$j++){
	print KVFIJIBATCH "c:\\fiji.app\\ImageJ-win64.exe -macro $dir\\$CROP[$j]\\kv_${CROP[$j]}_diff_${slice_diff}_${schichten}_${abstandschichten}.ijm\n";
	print KVFIJIMACRO "cd $dir\\$CROP[$j]\\ \nperl U:\\Backup\\daten\\Programmierung\\Minkowski\\KV_FIJI_macro_create.pl $slice_diff $schichten $abstandschichten\n";
}

print KVFIJIMACRO "cd ..\n";

close(KVFIJIBATCH);
close(KVFIJIMACRO);