#!/usr/bin/perl -w

use Tie::File;

sub varinit {
    @LINE=();
    @COMMENT=();
    @PIXEL=();
    %PIXEL=();
    $pore=0;
    $material=0;
    $anzahlgridpunkte=0;
}
################################
sub osver{
    open(OS, "ver |");
    while(<OS>) {
	$line=$_;
	chomp $line;
	print "$line\n";
	if($line =~ /^Microsoft/) {
	    $os = 1;
	}
	else { 
	    $os = 0;
	}
    }
    close(OS);
}
#######################
sub ppmimagein{
    @PIXEL=();
    # Die Kommentare belegen die ersten vier Zeilen
    $count=0;
    print "Subroutine ppmin gestartet.\n";
   
    open(PPMIN, "$datei") or die ("Die Datei $datei konnte nicht gefunden werden.\n");
    print "Bearbeite Datei $datei.\n";
    

    # Auslesen des Headers (Angabe der Pixel, Commentlines und Aufloesung
    while(<PPMIN>){
	$row=$_;
	chomp $row;
	if($row =~ /\#/){
	    # Rausfinden der Commentlines
	    push(@COMMENT, $row);
	}
	if($row=~ /^(\d{1,5}) (\d{1,5})$/){
	    $hoehe=$2;
	    $weite=$1;
	    $count=1;
	    print "Hoehe $hoehe und Weite $weite\n";
	}
        if($count==2){
	    last;
	}
	$count ++;
    }
    # Auslesen der Bilddaten
    while(<PPMIN>) {
	@LINE=();
	@INSERT=();
	$row=$_;
	chomp $row;
	@LINE=split(/ /, $row);
	my $linenum = $#LINE+1;
	# Bei Grayscale Bildern haben alle Pixel denselben RGB (=3) Wert
	for(my $k =0; $k<$linenum; $k+=3){
	    push(@INSERT, $LINE[$k]);
	}
	push (@PIXEL, @INSERT);
    }
    close(PPMIN);
    &pixelhash;
    
}

#######################
sub pixelhash {
    print "Subroutine Bild einlesen gestartet.\n";
    # Generieren des HASHES
    my $end=0;
    my $pixel = 0;
    my $aktuell=0;
    my $x=0;
    my $y=0; 
    my $z=0;
    # Pixel pro Bild
    # $bildpixel = $hoehe *$weite;

# Schnittlinien in Bildweite
# fuer Bildhoehe muss q und p getauscht werden => to do
    for($q=0;$q<$hoehe;$q++) {
	$pore=0;
	$material = 0;
	$matcount=0;
	$porecount=0;
	
	
	for($p=0;$p<$weite;$p++){
		
	    $aktuell=$end + $p;
	    # Fallunterscheidung zwischen der Schichtanordnung
	    if($art == 1) {
		# yx-Ebene, z = Ebenennormale
		$xgrenze=$hoehe;
		$ygrenze=$weite;
		$zgrenze=$schichtanzahl;
		$x=$q;
		$y=$p;
		$z=$schicht;
	    }
	   	
	    $key = "X"."$x"."Y"."$y"."Z"."$z";
	    
# 29.01.18
# Erstellen des Hashes %PIXEL
		$PIXEL{$key}=$PIXEL[$aktuell];
		
	}
	$end=$aktuell+1;
		
    }
    # Ende der Schleife
    
    # Bestimmung der Eigenschaften am Grid an den Knotenpunkten
    # Pore oder Material
    # Gridgroesse wird manuel uebermittelt, ebenso wir startx und starty
    # Gridgroesse -1, da bildpunkte bei 0 anfangen (grid unit length)
    $gridgroessex = (($weite - $startx)/$anzahlx)-1;
    #print "GX $gridgroessex\n";
    $gridgroessex = sprintf("%d", $gridgroessex);
    $gridlengthgesx=  $gridgroessex *$anzahlx;
    #print "GX $gridgroessex\n";
    $gridgroessey = (($hoehe - $starty)/$anzahly)-1;
     $gridgroessey = sprintf("%d", $gridgroessey);
     #    print "GY $gridgroessey\n";
      $gridlengthgesy=  $gridgroessey *$anzahly;
     
     $porositaet=0;
     $pore=0;
     $anzahlgridpunkte=0;
     
     # Testen auf Gridpunkte
     
    for($xgrid=$startx;$xgrid<$weite;$xgrid = $xgrid + $gridgroessex) {
	    
	    for($ygrid=$starty;$ygrid<$hoehe;$ygrid = $ygrid + $gridgroessey) {
		    my $testkey = "X"."$xgrid"."Y"."$ygrid"."Z"."$z";
		    
		    my $gridvalue = $PIXEL{$testkey};
		    if($gridvalue < $threshold){
			    # Bestimmung des Porenmaterials (P_Section)
			    $pore = $pore+1;
		    }
		    else{
			  $material=$material +1;
		    }
		    # Fortlaufende Anzahl der Gridpunkte (P)
		    $anzahlgridpunkte ++;
		    #print "Testkey $testkey \t GP = $anzahlgridpunkte \n";
	    }
    }
   $porositaet=($pore/$anzahlgridpunkte)*100;
   $porositaet=sprintf("%5.2f",$porositaet);
    print "Porositaet = $porositaet\n";
    
    print MINKPOR "$schicht\t$porositaet\t$anzahlgridpunkte\n";
	
	$intersectionx=0;
	# Testen auf Intersections in x-Richtung
	 for($ygrid=$starty;$ygrid<$hoehe;$ygrid = $ygrid + $gridgroessey) {
		 
		for($xgrid=$startx;$xgrid<$weite;$xgrid ++) {
			my $vorher=$xgrid;
			my $nachher = $xgrid+1;
			# letzter Pixel
			if($nachher>=$weite){
				$nachher = $vorher;
			}
			
			my $testkeyvorher = "X"."$vorher"."Y"."$ygrid"."Z"."$z";
			my $testkeynachher = "X"."$nachher"."Y"."$ygrid"."Z"."$z";
			    
			my $gridvaluevorher = $PIXEL{$testkeyvorher};
			my $gridvaluenachher = $PIXEL{$testkeynachher};
			# Pore - Pore
			if(($gridvaluevorher < $threshold) && ($gridvaluenachher  < $threshold) ){
				#print "Pore\n";
			}
			elsif(($gridvaluevorher > $threshold) && ($gridvaluenachher  > $threshold)) {
				#print "Material\n";
			}
			elsif(($gridvaluevorher < $threshold) && ($gridvaluenachher  > $threshold)) {
				#print "Intersection\n";
				$intersectionx++;
			}
			elsif(($gridvaluevorher > $threshold) && ($gridvaluenachher  < $threshold)) {
				#print "Intersection\n";
				$intersectionx++;
			}
			     
		}
		
		#print "Y-Grid $ygrid X-Grid $xgrid Intersection $intersectionx Gridlength Gesamtx = $gridlengthgesx\n";
	}
	
	$svx = 2*($intersectionx/($gridlengthgesx*$anzahly*$resolution));
	$lquerx = 2*$porositaet/($svx/2);
	#print "$svx (mm^-1) $lquerx (mu) gesamt-X $intersectionx\n";
	#print "Intersection x\n";
	#print "Y-Grid $ygrid X-Grid $xgrid Intersection Y $intersectiony Gridlength Gesamty = $gridlengthgesy\n";
	
	$intersectiony=0;
	# Testen auf Intersections in y-Richtung
	 for($xgrid=$startx;$xgrid<$weite;$xgrid = $xgrid + $gridgroessex) {
		 
		for($ygrid=$starty;$ygrid<$hoehe;$ygrid ++) {
			my $vorher=$ygrid;
			my $nachher = $ygrid+1;
			# letzter Pixel
			if($nachher>=$weite){
				$nachher = $vorher;
			}
			# Aenderung fehler war hier auf ygrid zu testen, ist aber xgrid
					
			my $testkeyvorher = "X"."$xgrid"."Y"."$vorher"."Z"."$z";
			my $testkeynachher = "X"."$xgrid"."Y"."$nachher"."Z"."$z";
			    
			my $gridvaluevorher = $PIXEL{$testkeyvorher};
			my $gridvaluenachher = $PIXEL{$testkeynachher};
			# Pore - Pore
			if(($gridvaluevorher < $threshold) && ($gridvaluenachher  < $threshold) ){
				#print "Pore\n";
			}
			elsif(($gridvaluevorher > $threshold) && ($gridvaluenachher  > $threshold)) {
				#print "Material\n";
			}
			elsif(($gridvaluevorher < $threshold) && ($gridvaluenachher  > $threshold)) {
				#print "Intersection\n";
				$intersectiony++;
			}
			elsif(($gridvaluevorher > $threshold) && ($gridvaluenachher  < $threshold)) {
				#print "Intersection\n";
				$intersectiony++;
			}
					     
		}
		
		#print "Y-Grid $ygrid X-Grid $xgrid Intersection Y $intersectiony Gridlength Gesamty = $gridlengthgesy\n";
	}
	
	$svy = 2*($intersectiony/($gridlengthgesy*$anzahlx*$resolution));
	#print "Intersection y\n";
	#print "Y-Grid $ygrid X-Grid $xgrid Intersection Y $intersectiony Gridlength Gesamty = $gridlengthgesy\n";
	$lquery = 2*$porositaet/($svy/2);
	
	$area =($anzahlx*$gridgroessex*$resolution)*($anzahly*$gridgroessey*$resolution);
	#print "$svy (mm^-1) $lquery (mu) gesamt-y $intersectiony\n";
	# String
	my $printstring = $schicht. "\;" .$svx. "\;" .$svy. "\;" .$lquerx. "\;" .$lquery. "\;" .$area. "\;" .$porositaet. "\;" .$intersectionx. "\;" .$intersectiony. "\;" .$gridgroessex. "\;" .$gridgroessey. "\;" .$gridlengthgesx. "\;" .$gridlengthgesy;
	$printstring =~ s/\./,/g;
	print STAT "$printstring\n";
	#print STAT "$schicht\t$svx\t$svy\t$lquerx\t$lquery\t$area\t$porositaet\t$intersectionx\t$intersectiony\t$gridgroessex\t$gridgroessey\t$gridlengthgesx\t$gridlengthgesy\n";
	
}
##########################

##########################
sub batch{
    # Ebene
    $art = $ARGV[0];
    #Dateiname
    $filename=$ARGV[1];
    # Erste Schicht
    $ersteschicht=$ARGV[2];
    #letzte Schicht
    $letzteschicht=$ARGV[3];
    # Schwellwert
    $threshold = $ARGV[4];
    # Gitterlinien in x
    $anzahlx = $ARGV[5];
    # Gitterlinien in y
    $anzahly = $ARGV[6];
    # Startx (Verschiebung positiv)
    $startx = $ARGV[7];
    # Starty (Verschiebung positiv)
    $starty = $ARGV[8];
    # AUfloesung
   $resolution = $ARGV[9];
   # Porendaten
   $poredata=$ARGV[10];
    
    print "$filename = Filename\n";
    
    if($os == 1) {
	@FILES=glob("${filename}_*.ppm");
    }
    else{
	open(PPMS, "ls *.ppm |");
	while(<PPMS>) {
	    my $line =$_;
	    chomp $line;
	    push(@FILES, $line);
	}
	close(PPMS);
    }
    $schichtdiranzahl=$#FILES+1;
    
    # Erstellen eines File-Hashes
    %FILES=();
    for(my $q=0;$q<$schichtdiranzahl;$q++){
	$file=$FILES[$q];
	my ($aktschicht) = $FILES[$q] =~ /^${filename}_(\d{4})/;
	$FILES{$aktschicht}=$file;
    }
    
    
    print "Es sind $schichtdiranzahl Dateien im Verzeichnis vorhanden.\n";
    
    if($schichtdiranzahl == 0) {
	print "Dateinotation: Dateiname_####_ wobei #### die Schichtzahl beschreibt\n";
	print "Keine Dateien im Verzeichnis gefunden.\nDas Programm beendet sich.\n";
	exit;
    }
     

    $schicht=0;
    $schichtanzahl=($letzteschicht+1)-$ersteschicht;
    $ersteschicht4=sprintf("%04d", $ersteschicht);
    $letzteschicht4=sprintf("%04d", $letzteschicht);
    
   open (MINKPOR, ">${filename}_${ersteschicht}_${letzteschicht}_${anzahlx}_${startx}_${anzahly}_${starty}_porositaet.txt");
   open(STAT, ">${filename}_${ersteschicht}_${letzteschicht}_${anzahlx}_${startx}_${anzahly}_${starty}_statistik.txt");
   print STAT "Schicht\;Sv_x\;Sv_y\;L_quer_x\;L_quer_y\;Flaeche\;Porositaet\;Intersection_x\;Intersection_y\;Gridgroesse_X\;Gridgroesse_Y\;Grid_Length_X\;Grid_Length_Y\n"; 
	
   
    for ($schichtzaehler=$ersteschicht;$schichtzaehler<$letzteschicht+1;$schichtzaehler++) {
	$schichtzaehler=sprintf("%04d", $schichtzaehler);
	$datei=$FILES{$schichtzaehler};
	print "\nAktuelle Schicht = $schichtzaehler\n";

	&ppmimagein;
	
        $schicht++;
	
    }
  close (MINKPOR);
  close(STAT);
  system("move ${filename}_${ersteschicht}_${letzteschicht}_${anzahlx}_${startx}_${anzahly}_${starty}_porositaet.txt ${filename}_${ersteschicht}_${letzteschicht}_${anzahlx}_${startx}_${anzahly}_${starty}_gridx_${gridgroessex}_gridy_${gridgroessey}_porositaet.txt");
}

##############################
&osver;
&varinit;
&batch;