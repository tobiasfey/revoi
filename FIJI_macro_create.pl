#!/usr/bin/perl -w
# wird nicht direkt aufgerufen nur von FIJI Batch
use Cwd;
my $dir = getcwd;

($fiji_name) = $dir =~ /\/(\w*)$/;
open(IN, "dir /b *.ppm |");
open(MACRO, ">$fiji_name.ijm");


while(<IN>){
	my $zeile=$_;
	chomp $zeile;
	my $file=$zeile;
	
	print MACRO "open(\"${dir}/$file\")\;\n";
	print MACRO "run(\"8-bit\")\;\n";
	print MACRO "setThreshold(0,120)\;\n";
	print MACRO "setOption(\"BlackBackground\", false)\;\n";
	print MACRO "run(\"Convert to Mask\")\;\nrun(\"Watershed\")\;\n";
	print MACRO "run(\"Set Measurements...\", \"area perimeter fit feret's kurtosis redirect=None decimal=3\")\;\n";
	print MACRO "run(\"Analyze Particles...\", \"  show=Ellipses clear\")\;\n";
	print MACRO "saveAs(\"Results\", \"${dir}/${file}_Results.csv\")\;\n";
	print MACRO "close()\;\n";
	print MACRO "selectWindow(\"$file\")\;\n";
	print MACRO "close()\;\n";
}

print MACRO "run(\"Quit\")\;\n";

close(MACRO);

