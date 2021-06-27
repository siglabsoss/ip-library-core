$fname = "test_data23.csv";
open XYZ, $fname or die "Error in open: $!";

$write_file = "i_inph_data.mif";
open IN, ">$write_file" or die "Error in open: $!";
@array = ();
$i = 0;
while (<XYZ>) {
    $hex = sprintf ("%X", $_);
    print IN ("$hex\n");
    $i++;
    }
close XYZ;
close IN;
