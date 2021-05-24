#!/usr/bin/perl
# Erzeugen der Fijii-Macros fuer eine ganze Serie und einer Batch Datei für FiJi

open(CROP, "cropdir");
@CROP=();

use Cwd;
my $dir = getdcwd();

open(FIJIBATCH, ">fiji_macro_batch.bat");
open(FIJIMACRO, ">fiji_macro_create.bat");

while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for(my $j =0;$j<$cropnumber;$j++){
	print FIJIBATCH "c:\\fiji.app\\ImageJ-win64.exe -macro $dir\\$CROP[$j]\\$CROP[$j].ijm\n";
	print FIJIMACRO "cd $dir\\$CROP[$j]\\ \nperl U:\\Backup\\daten\\Programmierung\\Minkowski\\FIJI_macro_create.pl\n";
}

print FIJIMACRO "cd ..\n";

close(FIJIBATCH);
close(FIJIMACRO);