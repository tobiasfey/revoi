#!/usr/bin/perl
# Batman Programmierung
# Erstellung der Datensets
use File::glob;

open(CROP, "cropdir");
@CROP=();

use Cwd;
my $dir = getdcwd();

open(BATMAN, ">batman.ctl");

while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;



print BATMAN ("[Dataset list]\n");

for(my $i =0; $i < $cropnumber; $i++){
	# Feststellen des Dateinamens
	my @FILE=glob("$CROP[$i]\\*.tif");
	$filename = $FILE[0];
	$filename =~ s/$CROP[$i]\\//g;
	
	print BATMAN ("Next=\@$i\n\[\@$i\]\n");
	print BATMAN ("File=$dir\\$CROP[$i]\\$filename\n");
	print BATMAN ("Info=0000000001000000FFFF00000000000000000000000000000000000000000000000000000000000000000000000000003C044532F4C58B3F00000000000000000000000000000000000000000000000004000000000000003D\n");
	@FILE=();
}
	
close(BATMAN);

