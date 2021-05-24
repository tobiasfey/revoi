#!/usr/bin/perl -w

$files = $ARGV [0];
$limit = $ARGV[1];
open(IN, $files);
open(OUT, ">out_files.bat");
open(CROP, "cropdir") or die ("Datei cropdir nicht gefunden");
@CROP=();


while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;
$filenumber = 0;
while(<IN>) {
	if($filenumber < $limit){
		my $image = $_;
		chomp $image;
		my $imagebmp = $image;
		$imagebmp =~ s/png/tif/g;
		my $imageppm = $image;
		$imageppm=~ s/png/ppm/g;
		for(my $j =0;$j<$cropnumber;$j++){
			my $dir = $CROP[$j];
			($size, $xcrop, $ycrop) = $dir =~ /(\d{3}x\d{3})_x(\d{3})_y(\d{3})/;
			print "$size, $xcrop, $ycrop\n";
			$xcrop = $xcrop +2;
			$ycrop = $ycrop +2;
			#print OUT "convert $image -crop $size\+$xcrop\+$ycrop -colorspace Gray $dir\\${size}_$image\n";
			print OUT "convert $image -crop $size\+$xcrop\+$ycrop $dir\\${dir}_$imagebmp\n";
			print OUT "convert $image -crop $size\+$xcrop\+$ycrop -compress none $dir\\${dir}_$imageppm\n";
			#print OUT "convert $image -crop $size\+$xcrop\+$ycrop $dir\\${size}_${xcrop}_${ycrop}_$imagebmp\n";
			#print OUT "convert $image -crop $size\+$xcrop\+$ycrop -compress none $dir\\${size}_${xcrop}_${ycrop}_$imageppm\n";
		}	
	}
	else{
	}
}


close(OUT);