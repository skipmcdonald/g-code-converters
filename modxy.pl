##  Copyright Skip McDonald 28 April 2014 - License Creative Commons
##  Non-Commercial use permitted with attribution.
##  Convert a g-code file to a 0,0,0 origin with all workpiece moves in negative direction
##  positive z clearance is programmable, X and Y should never go positive.

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
	print "\nThis perl scripts converts a g-code file to negative coordinates so that it will work with my CNC setup.\n As a side effect it pretties up files removeing extra spaces and moves the comments to the end of the line.\n  the command is:\n\n";
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



my $comment = 0;
my $cmt ="";
my $token = "";
my $sccmt = "";
my $index = " ";
my $move = 0;
my %maximums;
my $digits = 0;
my $infile =  $args{i} ? $args{i} : shift || '-';
if($debug) {print "$infile\n";}
open(INFILE, $infile) || die "Can't Open File: $infile\n";

my $outfile = $args{o} ? $args{o} : shift || '-';

if($debug) {print "$outfile\n";}
open(OUTFILE, ">$outfile") || die "Can't Open File: $outfile\n";

my @wholefile = <INFILE>;

if($debug){print "Lines =" , scalar @wholefile ; print "\n"; }

foreach(@wholefile) {  
	my $line = $_;
	($line =~ s/[;]+.*$//); ## blast everything after a ;
	($line =~  s/[(]+.*[)]+// ); ## blast () comments
	my @words = split /\s+|(?=;)|(?=[a-zA-Z]+[-.\d]+)/ , $line;
	foreach( @words){
if ($debug) {print "|$_|";}
	   if (/\d/){
	
		/^./;

	 	$index = uc($&);
		$digits = 0 + $';  # the numeric value of $' not its length
		if (exists $maximums{$index}) {
			if ($maximums{$index} < $digits ){ 
				$maximums{$index} = $digits;
			}
		}else{
			$maximums{$index} = $digits;
		}

	   }
	}
}


foreach(@wholefile) {  
	my $line = $_;
	$line =~ s/\n//g; ## zap newlines
	$line =~ s/\r//g; ## zap carriage returns
	if ($line =~ s/[;]+.*$//){
		$semicolon = 1; ## true
		$sccmt = $&;
	} ## everything after a ;
	if($line =~  s/[(]+.*[)]+// ) {
		$comment = 1; #i# true
		$cmt = $&;
	} ## () comments
	if ($line =~ m/\d\s/) { $spaces = 1;} else {$spaces = 0;}
	my @words = split /\s+|(?=;)|(?=[a-zA-Z]+[-.\d]+)/ , $line;
	foreach( @words){
	$token = $_;
if ($debug) {print "|$_|";}
	   if (/\d/){
	
		/^./;

	 	$index = uc($&);
		$digits = 0 + $';  # the numeric value of $' not its length

		if($index eq 'X') { $token = "X".($digits - $maximums{'X'}); }
		if($index eq 'I') { $token = "I".($digits - $maximums{'X'}); }
		if($index eq 'Y') { $token = "Y".($digits - $maximums{'Y'}); }
		if($index eq 'J') { $token = "J".($digits - $maximums{'Y'}); }
		

	   }
	  print OUTFILE "$token";  
	  &pspace;
	}
	if ($semicolon) {print OUTFILE "$sccmt"; $semicolon = 0;}
	if ($comment) {print OUTFILE "$cmt";$comment = 0;}
	print OUTFILE "\n";
}
if ($debug){ print "Maximums =" , %maximums ; print "\n"; }
print"\n"; ##no matter what put in a newline.
