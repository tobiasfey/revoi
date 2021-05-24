#!/usr/bin/perl
# Auswerten der Batman Files
#%THRES=();
$resolution = $ARGV[0];
if($resolution eq ""){
	print "Resolution angeben\n";
	exit;
}

use Cwd;
use Math::Trig;
use Statistics::Basic qw(:all);
# Setzen auf 6 Nachkommastellen
$Statistics::Basic::IPRES = 6;

$pi=pi();


open(RES, ">result_batman.txt");
print RES "Filename\tThreshold\tOV\tOS\tOS\/OV\tOV\/TV\tSMI\tFrac Dim\tEuler\tMean Strut (px)\tMean Cell (px)\tMean Strut (µm)\tMean Cell (µm)\n";

open(CROP, "cropdir") or die ("Datei cropdir nicht gefunden\n");
@CROP=();

use Cwd;
my $dir = getdcwd();

while(<CROP>){
	my $crop = $_;
	chomp $crop;
	push(@CROP, $crop);
}
close(CROP);

$cropnumber = $#CROP+1;

@BAT=();

for(my $j =0;$j<$cropnumber;$j++){
	($sizex, $sizey, $xkorr, $ykorr) = $CROP[$j]=~/^(\d{2,4})x(\d{2,4})_x(\d{3})_y(\d{3})/;
	my @IN=glob("$CROP[$j]\\*batman*.txt");
	#Aenderung einbauen
	foreach $file (@IN){
		print ("Dfile = $file\n");
		#my $liste) = $file =~ /liste_(\d{1,5}_\d{1,5})/;
		open(BAT, $file);
		while(<BAT>){
			my $zeile =$_;
			chomp $zeile;
			
			if($zeile =~ /3D\sanalysis$/) { 
				#print "Zeile $zeile lock = $lock\n";
				$lock=1;
			}
			elsif(($zeile =~ /Pixel size/) and ($lock ==1) ){
				($pixelsize) = $zeile =~ /\,(\d{1}\.\d{4}E\+\d{3})/;
				print "$pixelsize\n";
			}
			elsif(($zeile =~ /Lower grey threshold/) and ($lock ==1) ){
				($threshold) = $zeile =~ /\,(\d{1,3})/;
				#print "Threshold $threshold lock = $lock\n";
			}
			elsif($zeile =~ /hresholding/){
				  $lock =0;
				  #print "Zeile $zeile lock = $lock\n";
			}
			elsif(($zeile =~ /^Object volume/) and ($lock ==1) ){
				($ov) = $zeile =~ /\,(\d{1,3}\.\d{1,6}E(\+|-)\d{3})/;
			   #print "Zeile = $zeile\n";
			    #print "OV $ov lock = $lock\n";
			}
			elsif(($zeile =~ /^Percent object volume/) and ($lock ==1) ){
			    ($ovtv) = $zeile =~ /\,(\d{1,3}\.\d{1,6}E(\+|-)\d{3})/;
			   # print "Zeile = $zeile\n";
			    print "OVTV $ovtv lock = $lock\n";
			}
			elsif(($zeile =~ /^Object surface\,Obj/) and ($lock ==1) ){
			    ($os) = $zeile =~ /\,(\d{1,3}\.\d{1,6}E(\+|-)\d{3})/;
				   # print "Zeile = $zeile\n";
				    print "OS $os lock = $lock\n";
			}
			elsif(($zeile =~ /volume ratio/) and ($lock ==1) ){
				    ($osov) = $zeile =~ /\,(\d{1,3}\.\d{1,6}E(\+|-)\d{3})/;
				   # print "Zeile = $zeile\n";
				    print "VR $osov lock = $lock\n";
				  # $TRESH{$threshold}=($ov, $os, $osov,$ovtv);
				   #$TRESH{$threshold}=$ov;
				   #$ov=~s/\./,/g;
				   #$os=~s/\./,/g;
				   #$osov=~s/\./,/g;
				   $ovtv=$ovtv/100;
				   #$ovtv=~s/\./,/g;
			}	
			elsif(($zeile =~ /SMI/) and ($lock ==1) ){
				
				($smi) =  $zeile =~ /\,(-?\d{1}\.\d{1,6}E(\+|-)\d{3})/;
				#$smi =~s/\./,/g; 
				print "SMI $smi\n";
			}
			elsif(($zeile =~ /Structure thickness,/) and ($lock ==1) ){
				($meanstrut) =  $zeile =~ /\,(\d{1}\.\d{1,6}E(\+|-)\d{3})/;
				$meanstrutmu = $meanstrut * $resolution;
				#$meanstrut =~s/\./,/g; 
				#$meanstrutmu =~s/\./,/g; 
			}
			elsif(($zeile =~ /Structure separation,/) and ($lock ==1) ){
				($meancell) =  $zeile =~ /\,(\d{1}\.\d{1,6}E(\+|-)\d{3})/;
				$meancellmu = $meancell * $resolution;
				#$meancell =~s/\./,/g; 
				#$meancellmu  =~s/\./,/g; 
				#print RES "$CROP[$j]\t$threshold\t$ov\t$os\t$osov\t$ovtv\t$smi\t$meanstrut\t$meancell\n";
			}
			elsif(($zeile =~ /Fractal dimension,/) and ($lock ==1) ){
				($fracdim) =  $zeile =~ /\,(\d{1}\.\d{1,6}E(\+|-)\d{3})/;
				#$fracdim =~s/\./,/g; 
				print "Fracdim $fracdim\n";
				#print RES "$CROP[$j]\t$threshold\t$ov\t$os\t$osov\t$ovtv\t$smi\t$fracdim\t$meanstrut\t$meancell\n";
			}
			elsif(($zeile =~ /Euler number,/) and ($lock ==1) ){
				($euler) =  $zeile =~ /\,(-?\d{1,6})/;
				#$fracdim =~s/\./,/g; 
				print "Euler $euler\n";
				
				my $printstring = $CROP[$j] . "\t" . $threshold . "\t" . $ov . "\t" . $os . "\t" . $osov . "\t" . $ovtv . "\t" . $smi . "\t" . $fracdim . "\t" . $euler . "\t" . $meanstrut . "\t" . $meancell . "\t" . $meanstrutmu . "\t" . $meancellmu ;
				$printstring =~s/\./,/g; 
				#print RES "$CROP[$j]\t$threshold\t$ov\t$os\t$osov\t$ovtv\t$smi\t$fracdim\t$euler\t$meanstrut\t$meancell\t$meanstrutmu\t$meancellmu \n";
				print RES "$printstring\n";
				push (@BAT, [$sizex, $sizey, $threshold,$ov,$os,$osov,$ovtv,$smi,$fracdim,$euler,$meanstrut,$meancell,$meanstrutmu,$meancellmu]);
			}
			
		}	
		close(BAT);
			
	}	
		
}
close(RES);

$batnumber = $#BAT+1;

open(BATNORM, ">batman_norm_all_sum.csv");
print BATNORM ("X-Size\;Resolution (µm\;Mean OV\;Mean OV Error\;Mean OV\/TV\;Mean OV \/TV Error\;Mean SMI\;Mean SMI Error\;Mean Frac Dim\;Mean Frac Dim Error\;Mean Euler\;Mean Euler Error\;Mean Strut\;Mean Strut Error\;Mean Cell\;Mean Cell Error\n");
for(my $i=200;$i<700;$i=$i+100){
	@OV=();
	@OVTV=();
	@SMI=();
	@FRACDIM=();
	@EULER=();
	@MEANSTRUTMU=();
	@MEANCELLMU=();
	open(BATSUM, ">batman_sum_${i}x${i}.csv");
		print BATSUM ("X-Size\;Y-Size\;Threshold\;OV\;OS\;OS\/OV\;OV\/TV\;SMI\;Frac Dim\;Euler\;Mean Strut (px)\;Mean Cell (px)\;Mean Strut (µm)\;Mean Cell (µm)\n");
	for(my $k=0;$k<$batnumber;$k++){
		if($BAT[$k][0] == $i){
			push (@OV, $BAT[$k][3]);
			push (@OVTV, $BAT[$k][6]);
			push (@SMI, $BAT[$k][7]);
			push (@FRACDIM, $BAT[$k][8]);
			push (@EULER, $BAT[$k][9]);
			push (@MEANSTRUTMU, $BAT[$k][12]);
			push (@MEANCELLMU, $BAT[$k][13]);
			print BATSUM "$BAT[$k][0]\;$BAT[$k][1]\;$BAT[$k][2]\;$BAT[$k][3]\;$BAT[$k][4]\;$BAT[$k][5]\;$BAT[$k][6]\;$BAT[$k][7]\;$BAT[$k][8]\;$BAT[$k][9]\;$BAT[$k][10]\;$BAT[$k][11]\;$BAT[$k][12]\;$BAT[$k][13]\n";
		}
	}
	close(BATSUM);
	$ovmean= mean(@OV);
	$ovstddev=stddev(@OV);
	$ovtvmean = mean(@OVTV);
	$ovtvstddev = stddev(@OVTV);
	$smimean=mean(@SMI);
	$smistddev = stddev(@SMI);
	$fracmean= mean(@FRACDIM);
	$fracstddev = stddev(@FRACDIM);
	$eulermean = mean(@EULER);
	$eulerstddev = stddev(@EULER);
	$meanstrutmu = mean(@MEANSTRUTMU);
	$meanstrutmustdev = stddev(@MEANSTRUTMU);
	$meancellmu = mean(@MEANCELLMU);
	$meancellmustdev = stddev(@MEANCELLMU);
	
	my $printstring = $i . "\;" . $resolution . "\;" . $ovmean . "\;" . $ovstddev . "\;" . $ovtvmean . "\;" . $ovtvstddev . "\;" . $smimean . "\;" . $smistddev . "\;" . $fracmean . "\;" . $fracstddev . "\;" . $eulermean . "\;" . $eulerstddev . "\;" . $meanstrutmu . "\;" . $meanstrutmustdev . "\;" . $meancellmu . "\;" . $meancellmustdev;
	$printstring =~s/,//g; 
	$printstring =~s/\./,/g; 
	print BATNORM ("$printstring\n");
	#print BATNORM ("$i\;$ovmean\;$ovstddev\;$ovtvmean\;$ovtvstddev\;$smimean\;$smistddev\;$fracmean\;$fracstddev\;$eulermean\;$eulerstddev\;$meanstrutmu\;$meanstrutmustdev\;$meancellmu\;$meancellmustdev\n");
	
}
   
close(BATNORM);


