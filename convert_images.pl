#!/usr/bin/perl -w
# Convert Bilder nach PPM

use File::Glob;
open(OUT, ">convert_files.bat");
open(CROP, "cropdir");
@CROP=();


while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

for ($i=0;$i<$cropnumber;$i++){
	my $dir = $CROP[$i];
	print "Dir = $dir\n";
	@FILES= glob("$dir\/*.tif");
	print "Anzahl Dateien $#FILES\n";
	foreach $element (@FILES){
		 $file = $element;
		print "Element = $element\n";
		$file_new =$file;
		$file_new =~ s/.tif/.ppm/g;
		print OUT "convert $file -compress none $file_new\n";
	}
}
close(OUT);