##  Copyright Skip McDonald 17 April 2014 - License Creative Commons
##  Non-Commercial use permitted with attribution.
##  Convert Canned G83 sequences to equivalent G codes for platforms that don't support canned sequences.

use strict;
use warnings;

### Global variables...
my %values = ();
my $incr = 5;
my $linenumber = 0;
my $ztraverse = 1; #zero is probably a bad safety height, assume Z goes negative into work piece so positive is above it.

sub peck {
	print"peck\n";
# decided not to use parameters... look for globals 
#	my $vx = $_[0];
#	my $vy = $_[1];
#	my $vz = $_[2];
#	my $vr = $_[3];
#	my $vq = $_[2];

	print OUTFILE "G0 X";
	print OUTFILE $values{"X"};
	print OUTFILE " Y";
	print OUTFILE $values{"Y"};
	print OUTFILE " Z";
	print OUTFILE $ztraverse;
	print OUTFILE " ;\n";
	#####peck logic here....
	$linenumber = $linenumber + $incr;
	print OUTFILE "N";
	print OUTFILE $values{"N"} + $linenumber;
	print OUTFILE " ";
	print OUTFILE "G0 Z";
	print OUTFILE $values{"R"};
	print OUTFILE " ;\n";
	my $zhole = $values{"Z"};
	my $drilled_distance = $values{"R"};
	while ($zhole != $drilled_distance){
	$drilled_distance = $drilled_distance - $values{"Q"};
	if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
	$linenumber = $linenumber + $incr;
	print OUTFILE "N";
	print OUTFILE $values{"N"} + $linenumber;
	print OUTFILE " G1 Z";
	print OUTFILE $drilled_distance ;
	print OUTFILE " F";
	print OUTFILE $values{"F"};
	print OUTFILE " ;\n";
	if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
	$linenumber = $linenumber + $incr;
	print OUTFILE "N";
	print OUTFILE $values{"N"} + $linenumber;
	print OUTFILE " G0 Z";
	print OUTFILE $values{"R"};
	print OUTFILE " "; # \n comes in the simicolon logic or below.
	if($drilled_distance != $zhole){ # back into the hole if we have more to drill.
		print OUTFILE ";\n";
		$linenumber = $linenumber + $incr;
		print OUTFILE "N";
		print OUTFILE $values{"N"} + $linenumber;
		print OUTFILE " G0 Z";
		print OUTFILE $drilled_distance +.01 ;
		print OUTFILE " ;\n"; 
		
	} 


	}# end while..



}
my $canned = 0;
my $numbered = 0;
my $comment = 0;
my $cmt ="";
my $token = "";
my $semicolon = 0;
my $sccmt = "";
my $index = " ";
my $move = 0;
my $infile = $ARGV[0];
open(INFILE, $infile) || die "Can't Open File: $infile\n";

my $outfile = $ARGV[1];

open(OUTFILE, ">$outfile") || die "Can't Open File: $outfile\n";

while(<INFILE>) {
	$numbered = 0;
	$comment = 0;
	$semicolon = 0;
	$move = 0;
	s/\n//; # chomp line feeds
	s/\r//; # chomp carriage returns
	
	my $line = $_;
	
	if ( $line =~ s/[(]+.*[)]+// ) {
	$cmt = $&;
	print "Comment $cmt\n";
	$comment = 1;
	}
	if ( $line =~ s/[;]+.*$//) {
	$semicolon = 1;
	$sccmt = $&; #save the semicolon and any comment
	}
	my @words = split ' ',$line;
	foreach( @words){
	if (/\d/){
	
		/^./;

	 	$index = uc($&);
		$values{$index} = 0 + $'; # the numeric value of $' not its length
		if( uc($&) eq "G"){ 
			$token = "$_ ";

			print "g$_ "; 
			if( $' == 80) { 
				$canned = 0; 
				$token = ""; #don't output the command
			# also if $moved then also process the line so far
				if($move){
					print "PROCESS MOVE BEFORE G80\n";
					$move = 0; #clear the $move flag
					&peck;
#					print OUTFILE "G0 X";
#					print OUTFILE $values{"X"};
#					print OUTFILE " Y";
#					print OUTFILE $values{"Y"};
#					print OUTFILE " Z";
#					print OUTFILE $ztraverse;
#					print OUTFILE " ;\n";
#				#####peck logic here....
#					$linenumber = $linenumber + $incr;
#					print OUTFILE "N";
#					print OUTFILE $values{"N"} + $linenumber;
#					print OUTFILE " ";
#					print OUTFILE "G0 Z";
#					print OUTFILE $values{"R"};
#					print OUTFILE " ;\n";
#				my $zhole = $values{"Z"};
#				my $drilled_distance = $values{"R"};
#				while ($zhole != $drilled_distance){
#					$drilled_distance = $drilled_distance - $values{"Q"};
#					if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
#					$linenumber = $linenumber + $incr;
#					print OUTFILE "N";
#					print OUTFILE $values{"N"} + $linenumber;
#					print OUTFILE " G1 Z";
#					print OUTFILE $drilled_distance ;
#					print OUTFILE " F";
#					print OUTFILE $values{"F"};
#					print OUTFILE " ;\n";
#					if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
#					$linenumber = $linenumber + $incr;
#					print OUTFILE "N";
#					print OUTFILE $values{"N"} + $linenumber;
#					print OUTFILE " G0 Z";
#					print OUTFILE $values{"R"};
#					print OUTFILE " ;\n";
#					if($drilled_distance != $zhole){ # back into the hole if we have more to drill.
#					$linenumber = $linenumber + $incr;
#						print OUTFILE "N";
#						print OUTFILE $values{"N"} + $linenumber;
#						print OUTFILE " G0 Z";
#						print OUTFILE $drilled_distance +.01 ;
#						print OUTFILE " ;\n";
#					}
#					
#				} # end while..
#
#
#
#
				} #end if ($move)
			} 
			if($' == 83) {
				$ztraverse = $values{"Z"};
				$canned = 1;
				$token = ""; #don't output the command
				if($move){
					$move = 0;
					print OUTFILE ";\n";
					$linenumber = $linenumber + $incr;
					print OUTFILE "N";
					print OUTFILE $values{"N"} + $linenumber;
					print OUTFILE " ";
				} 
				} #start canned drill translation
			print OUTFILE "$token";

		}else{
			if(uc($&) ne "N"){ 
				$move = 1; 
				print "v$_ ";
				if(!$canned){ print OUTFILE "$_ ";}
			}else{
				$numbered = 1;
				print "n$_ ";
				print OUTFILE "N";
				print OUTFILE $linenumber + $';
				print OUTFILE " ";
			}
		}
	}else{
		print "?$_ ";
		print OUTFILE "$_ ";
	}
	
	
	}
	
	if($canned){
		if($move){ &peck ;}
	}
	if($semicolon) { print OUTFILE "$sccmt" ;}	
	print OUTFILE " (" ;	
	print OUTFILE "$line";
	if($comment) {print OUTFILE "$cmt";}  # relocate comment to end
	print OUTFILE ")" ;	
	print OUTFILE "\n";

}
print %values;
