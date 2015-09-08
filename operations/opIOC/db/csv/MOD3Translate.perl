#!/usr/bin/perl
# Modicon Translation program to go from csv file to the appropriate substituion files
# Sep, 20th, 2012. Put / in front of dollar signs, and added
#"file \"\$(ASYN)/db/asynRecord.db\" { pattern\n";
#along with comment to selections 1 and 2

print "This program translates the Modicon csv files to the appropriate substitution files...\n";

print "Select which file to be converted....\n";
print "1-MOD3ReadOutputCoils1\n";
print "2-MOD3ReadOutputCoils2\n";
print "3-MOD3Read256Inputs\n";
print "4-MOD3Out\n";
print "Enter Selection:\n";
$selection=getc;
print "Your selection is $selection\n";

if($selection==1)
{
	open INFILE,"MOD3OutputsWithPVAlias1.csv" or die $!;
	open(OUTFILE,"> MOD3ReadOutputCoilsAlias1.substitutions");
	$port="MOD3_Coil1";
	print OUTFILE "# substitutions file for 1400 read bits\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Coils 1 - 1400 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,    DESC,  ALIAS}\n";
}
elsif($selection==2)
{
	open INFILE,"MOD3OutputsWithPVAlias2.csv" or die $!;
	open(OUTFILE,"> MOD3ReadOutputCoilsAlias2.substitutions");
	$port="MOD3_Coil2";
	print OUTFILE "# substitutions file for 1400 read bits\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Coils 2000 - 3399 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,    DESC,  ALIAS}\n";
}
elsif($selection==3)
{
        open INFILE,"MOD3InputsWithPVAlias.csv" or die $!;
	open(OUTFILE,"> MOD3ReadInputCoilsAlias.substitutions");
	$port="MOD3_Input";
	print OUTFILE "# substitutions file for 256 Inputs\n";
	print OUTFILE "\n";
	print OUTFILE "# These are Inputs 1 - 256 in the modicon.\n";
	print OUTFILE "file \"../../db/bi_bitAlias.template\" { pattern\n";
	print OUTFILE "{R,         PORT,             OFFSET,   ZNAM,   ONAM,  ZSV,       OSV,    SCAN,   DESC,   ALIAS}\n";
}
elsif($selection==4)
{
        open INFILE,"MOD3WritesWithPVAlias.csv" or die $!;
	open(OUTFILE,"> MOD3OutAlias.substitutions");
	print OUTFILE "# MasterControlOut.substitutions\n";
	print OUTFILE "# writing 256 Coils, in one shot, from Master-Control\n";
	print OUTFILE "\n";
	print OUTFILE "#Waveform array for writing out the Coils\n";
	print OUTFILE "file \"../../db/intarray_out.template\" { pattern\n";
	print OUTFILE "{P,           R,            PORT,                  NELM}\n";
	print OUTFILE "{MOD3:,         CnOutWArray,  MOD3_Output,    368}\n";
	print OUTFILE "}\n\r";
	print OUTFILE "#Binary Out Coils\n";
	print OUTFILE "file \"../../db/MOD3BOAlias.template\" { pattern\n";
	print OUTFILE "{P,             ZNAM,           ONAM, DESC, ALIAS}\n";
}
else
{
	print "No Selection made...exiting program...\n";
	exit(0);
}

# Read in the file...

my(@lines)=<INFILE>;
my($line);
$lineCt=0;

foreach $line (@lines)
{
	# Skip the first three lines in the csv file
	if($lineCt<3)
	{
		print "Skip this line..\n";
	}
	else
	{
		chomp($line); 		#strip off the trailing newline
		@fields=split(',',$line);
		if($selection<4)
		{
			printf OUTFILE ("{%s,	%s,	%s,	%s,	%s,	NO_ALARM,	NO_ALARM,	\"I/O Intr\",	%s,	%s}\n", $fields[2],$port,$fields[0],$fields[4],$fields[3],$fields[1],$fields[6]);
		}
		else
		{
			printf OUTFILE ("{%s,	%s,	%s,	%s,	%s}\n", $fields[2],$fields[4],$fields[3],$fields[1],$fields[6]);
		}

	}
	$lineCt++;	
}
print OUTFILE "}";
print "\nFile successfully converted into substitution file!\n";
close INFILE;
close OUTFILE;


	
