##  Copyright Skip McDonald 17 April 2014 - License Creative Commons
##  Non-Commercial use permitted with attribution.
##  Convert Canned G83 sequences to equivalent G codes for platforms that don't support canned sequences.
####To Do:
##  Dwell Pxx.xx sequence is ignored - sorry   will convert to G4 some time.
##  only converts G83 and not G81 - another program does that fine we just need to combine them.

use strict;
use warnings;

use Getopt::Std;
### Process arguments
my %args;

getopts ('i:o:dDsh', \%args);

### Global variables...
my $debug = $args{d}; #print debug messages to screen
my $debugout = $args{D}; # include a copy of each input line as a comment in the out file.
my %values = ();
my $incr = 1; # positive incriment of line numbers - change to match input file.
my $linenumber = 0;
my $numbered = 0;
my $spaces = 0;
my $ztraverse = 1; #zero is probably a bad safety height, assume Z goes negative into work piece so positive is above it.
   $values{"Z"} = 0;  #avoid error when no value of Z exists prior to G83
my $dwell = 0; # no dwell
my $semicolon = 0;
my $peckit = 0;
my $drillit = 0;
my $spstop = 0;
my $feedout = 0;

if ($args{h}){ &HELP_MESSAGE(); exit;}
sub HELP_MESSAGE {
	print "\nThis perl scripts converts a file containing G83 G80 drill plans to simple G-codes( G0 G1 G4 ) that do the same thing.\nOutput format tries to match the input lines as best it can.\nThe format of the command is:\n\n";
	print "[perl] $0 [-d -D -i {infile} -o {outfile} -s] [{infile} {outfile}\n\t -d turn on debug\n\t -D include infile lines as comments in the outfile\n\t -s turn off progress dots (used with standard out)\n\t -h prints this help text\n";
	print "\t [-i filename] specifies an input file\n";
	print "\t [-o filename] specifies an output file\n";
	print "\n\nIf infile and/or outfile are omited STDIN and/or STDOUT will be used. \nThis is useful for pipe and IO redirection in scripts.\n";
}
sub pnlsemi { #print \n and optionaly print semicolons
	if ($semicolon) {
	print OUTFILE ";\n";
	}else{
	print OUTFILE "\n";
	}

}
sub pspace {
	if ($spaces) {
	print OUTFILE " ";
	}
	
}

sub plnum { #print line numbers

	if($numbered){
		$linenumber = $linenumber + $incr;
		print OUTFILE "N";
		print OUTFILE $values{"N"} + $linenumber;
		&pspace;
	}
}


sub drill { # set values to drill all at once with then call &peck
	$values{Q} = $ztraverse - $values{Z};
	&peck;
}

sub peck {
	if($debug){print"peck $peckit\ndrill $drillit\n";}
	print OUTFILE "G0";
	&pspace;
	print OUTFILE "X";
	print OUTFILE $values{"X"};
	&pspace;
	print OUTFILE "Y";
	print OUTFILE $values{"Y"};
	&pspace;
	print OUTFILE "Z";
	print OUTFILE $ztraverse;
	&pspace;
	&pnlsemi;
	&plnum;
	print OUTFILE "G0";
	&pspace;
	print OUTFILE "Z";
	print OUTFILE $values{"R"};
	&pspace;
	&pnlsemi;
	my $zhole = $values{"Z"};
	my $drilled_distance = $values{"R"};
	while ($zhole != $drilled_distance){
	$drilled_distance = $drilled_distance - $values{"Q"};
	if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
		&plnum;
	print OUTFILE "G1";
	&pspace;
	print OUTFILE "Z";
	print OUTFILE $drilled_distance ;
	&pspace;
	print OUTFILE "F";
	print OUTFILE $values{"F"};
	&pspace;
	&pnlsemi;
	if($dwell > 0){
		&plnum;
		print OUTFILE "G4";
		&pspace;
		print OUTFILE "P"; ## I think P is the right dwell parameter
		&pspace;
		print OUTFILE $dwell;
		&pspace;
		&pnlsemi;
	}
	if($drilled_distance < $zhole){ $drilled_distance = $zhole;}
		&plnum;
	if($spstop){print OUTFILE "M5"; &pspace;} #stop spindle
	print OUTFILE $feedout ? "G1" : "G0";
	&pspace;
	print OUTFILE "Z";
	print OUTFILE $values{"R"};
	&pspace;
	if($feedout){
		print OUTFILE "F";
		print OUTFILE $values{"F"};
		&pspace;
	}
	if($drilled_distance != $zhole){ # back into the hole if we have more to drill.
		&pnlsemi;
		&plnum;
		print OUTFILE "G0";
		&pspace;
		print OUTFILE "Z";
		print OUTFILE $drilled_distance +.01 ;
		&pspace;
		&pnlsemi;
		
	} 

	if($spstop){
		&plnum; 
		print OUTFILE "M3"; 
		&pspace; 
		&pnlsemi;} #restart stopped spindle

	}# end while..



}
my $canned = 0;
##my $numbered = 0; # uncomment this to not put line numbers on the canned output.
my $comment = 0;
my $cmt ="";
my $token = "";
my $sccmt = "";
my $index = " ";
my $move = 0;
my $infile =  $args{i} ? $args{i} : shift || '-';
if($debug) {print "$infile\n";}
open(INFILE, $infile) || die "Can't Open File: $infile\n";

my $outfile = $args{o} ? $args{o} : shift || '-';

if($debug) {print "$outfile\n";}
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
	if($debug) { print "Comment $cmt\n"; }
	$comment = 1;
	}
	if ( $line =~ s/[;]+.*$//) {
	$semicolon = 1;
	$sccmt = $&; #save the semicolon and any comment
	}
	if ($line =~ m/\d\s/){$spaces = 1;}else{$spaces = 0;} #does this line have spaces after commands
#	my @words = split ' ',$line;
	my @words = split /\s+|(?=;)|(?=[a-zA-Z]+[-.\d]+)/ , $line;
	foreach( @words){
	if (/\d/){
	
		/^./;

	 	$index = uc($&);
		$values{$index} = 0 + $'; # the numeric value of $' not its length
		if($canned) { 
		if ($index eq "R"){
			if($ztraverse < (0 + $')){
				$ztraverse = 0 + $';
			}
		} ##fix the case where R is higher than Z traverse
		if ( ($index eq "Q") and 0 >= $'){ die "Negative or zero Q not allowed";} 
		if ($index eq "P"){$dwell  = 0 + $';}
		}  ## $canned
		if( $index eq "G"){ 
			$token = "$_ ";

if($debug){		print "g$_ "; }
			if( $' == 80) { 
				if($canned){	$token = "";} #don't output the command
				$canned = 0; 
				
			# also if $moved then also process the line so far
				if($move){
if($debug){				print "PROCESS MOVE BEFORE G80\n";}
					if($peckit){&peck; }
					elsif($drillit){&drill; }
					else{ die "Unsupported Canned Cycle\n"; }
					$move = 0; #clear the $move flag
				} #end if ($move)
				$dwell = 0;
				$spstop = 0;
				$feedout = 0;
				$peckit = 0;
				$drillit = 0;
			} 
			if(($' >= 81) and ($' <= 89)) {
				$ztraverse = $values{"Z"};
				$dwell = 0; #dwell shouldn't be sticky
				if ($' == 83){$peckit = 1; $feedout = 0; } 
				if ($' == 86){$drillit = 1; $spstop = 1; $feedout = 0;}
				if ($' == 81){$drillit = 1; $feedout =0 ; $dwell = 0;}
				if ($' == 82){$drillit = 1; $feedout = 0; }
				if ($' == 85){$drillit = 1; $feedout = 1; $dwell = 0; }
				if ($' == 89){$drillit = 1; $feedout = 1; }
				if ($' == 84){ die "G84 not supported\n"; }
				if ($' == 87){ die "G87 not supported\n"; }
				if ($' == 88){ die "G88 not supported\n"; }

				$canned = 1;
				$token = ""; #don't output the command
				if($move){
					$move = 0;
					&pnlsemi;
					$linenumber = $linenumber + $incr;
					print OUTFILE "N";
					print OUTFILE $values{"N"} + $linenumber;
					&pspace;
				} # some command caused a move prior to G83 - give us a fresh line for aesthetics
				} #start canned drill translation
			print OUTFILE "$token";

		}else{
			if($index ne "N"){ 
				$move = 1; 
if ($debug){			print "v$_ ";}
				if(!$canned){ print OUTFILE "$_ ";}
			}else{
				$numbered = 1;
if ($debug){			print "n$_ ";}
				print OUTFILE "N";
				print OUTFILE $linenumber + $';
				&pspace;
			}
		}
	}else{
if ($debug){	print "?$_ ";}
		print OUTFILE "$_ ";
	}
	
	
	}
	
	if($canned){
		if($move){ 
		
			if($peckit){&peck; }
			elsif($drillit){&drill; }
			else{ die "Unsupported Canned Cycle\n"; }
		}
	}
	if($semicolon) { print OUTFILE "$sccmt" ;}	
if($debugout){
		print OUTFILE " (" ;	
		print OUTFILE "$line";
	}
	if($comment) {print OUTFILE "$cmt";}  # relocate comment to end
if($debugout){ 	print OUTFILE ")" ;}

	print OUTFILE "\n"; #done with this line!!
	if (!$args{s} and !$debug){ print ".";}

}
if ($debug){print %values;}
print"\n";
