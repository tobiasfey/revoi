#!/usr/bin/perl -w

use Cwd;
use Math::Trig;
use Statistics::Basic qw(:all);
# Setzen auf 6 Nachkommastellen
$Statistics::Basic::IPRES = 6;

open(IN, "dir /b kv_sum*.csv |");
open(OUT, ">kv_norm_all.csv");
while(<IN>){
	@DATA =();
	@KV=();
	
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
		
		push(@KV, $SORTDATA[$j][6]);
		
	}
	}
	
	$meankv= mean(@KV);
	$meankverrror = stddev(@KV);
	
	$meankv =~ s/\./,/g;
	$meankverrror =~ s/\./,/g;
	($voi) =$SORTDATA[0][0] =~ /(\d{3})x/;
	print OUT "$voi\;$SORTDATA[0][0]\;$SORTDATA[0][2]\;$meankv\;$meankverrror\n";
	
	
}


	

