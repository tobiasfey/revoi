#!/usr/bin/perl -w

use Cwd;
use Math::Trig;
use Statistics::Basic qw(:all);
# Setzen auf 6 Nachkommastellen
$Statistics::Basic::IPRES = 6;

open(IN, "dir /b jeff_norm_sum*.csv |");
open(OUT, ">jeff_norm_all.csv");
while(<IN>){
	@DATA =();
	@POROSITAET=();
	@POROSITAETERROR=();
	@JEFF=();
	@JEFFERROR=();
	$file = $_;
	chomp $file;
	#print "Bearbeite $file\n";
	open(INDATA, "$file");
	while(<INDATA>){
			my $zeile =$_;
			chomp $zeile;
			$zeile =~ s/,/\./g;
			if($zeile =~/^\d/){
				my @LIST = split (/\;/, $zeile);
				push(@DATA, ([@LIST]));
			}
		}
	close(INDATA);
	# Auswerteteil
	@SORTDATA = sort{$a ->[2]  cmp  $b -> [2]} @DATA;
	$numdata =$#DATA+1;
	
	for(my $j =0; $j<$numdata;$j++){
	#foreach $i (@SORTDATA) {
	if($SORTDATA[$j][2] eq $SORTDATA[0][2] ){
		push(@POROSITAET, $SORTDATA[$j][13]);
		push(@POROSITAETERROR, $SORTDATA[$j][14]);
		push(@JEFF, $SORTDATA[$j][16]);
		push(@JEFFERROR, $SORTDATA[$j][17]);
		#print "$SORTDATA[$j][3]\n";
	}
	}
	$meanporositaet = mean(@POROSITAET);
	$meanporositaet_error = mean(@POROSITAETERROR);
	$meanjeff = mean(@JEFF);
	$meanjefferrror = mean(@JEFFERROR);
	
	$meanporositaet=~ s/\./,/g;
	$meanporositaet_error =~ s/\./,/g;
	$meanjeff =~ s/\./,/g;
	$meanjefferrror =~ s/\./,/g;
	($voi) =$SORTDATA[0][0] =~ /(\d{3})x/;
	print OUT "$voi\;$SORTDATA[0][0]\;$SORTDATA[0][2]\;$meanporositaet\;$meanporositaet_error\;$meanjeff\;$meanjefferrror\n";
	
	
}


	

