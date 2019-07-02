#!/bin/bash

USAGE="./generateGraph_Diameter.sh [path_to_aln_file] [path_to_newick_file] [repititions]"
DESCRIPTION="Gets error data for AlignmentErrorRemoval by varying the diameter of input alignments\n\t\t\tThe diameters will be in the range [0, 0.5], in increments of 0.05\n\t\t\tThe value of k is set at 11\n\t\t\tThe length of an error is set at 88 (8*k)\n\t\t\tThe number of erroneous alignments is n/20, where n is the total number of alignments"
# Checks parameters
if [ $# -ne 3 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	echo
	echo -e "\tDescription:\t""$DESCRIPTION"
	exit 1
fi

diameter_ranges=(0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5)
num_err_aln_divisor=20
len_of_err_multiplier=8
value_of_k=11
aln_file=$1
newick_file=$2
repititions=$3

output_file="DATA_OUTPUT"
format_output_file="FORMATTED_OUTPUT"
> $output_file
> $format_output_file
echo -e "$aln_file\tmin_diameter:${diameter_ranges[0]}\tmax_diameter:${diameter_ranges[${#diameter_ranges[@]}-1]}\trepititions:$repititions\tFP\tFN\tTP\tTN" > $format_output_file

# Loops through the diameter ranges and then the number of repititions for each range
for (( i=0; i<${#diameter_ranges[@]}-1; i++ )); do
	min_diameter=${diameter_ranges[$i]}
	max_diameter=${diameter_ranges[$(($i+1))]}
	echo "Choosing alignments from $aln_file with diameter range [$min_diameter, $max_diameter]..."
	python chooseAlignmentsByDistance.py $newick_file $aln_file $min_diameter $max_diameter
	for (( j=0; j<$repititions; j++ )); do
		description="$aln_file\tmin_diameter:$min_diameter\tmax_diameter:$max_diameter\trepitition:$j"
		num_alignments=$((`wc -l < chosen_alignments.fasta` / 2))
		echo "Generating error model for diameter range [$min_diameter, $max_diameter], repitition $j..."
		python generateErrorModel.py chosen_alignments.fasta $(($num_alignments / $num_err_aln_divisor)) $(($value_of_k * $len_of_err_multiplier))
		echo "Running the correction algorithm..."
		julia correction.jl -k $value_of_k -m X -a N error.fasta > OUTPUT 2> /dev/null
		echo "Getting error rates for the correction algorithm..."
		python getErrorRates.py reformat.fasta error.fasta OUTPUT $description >> $output_file 2>> $format_output_file
		rm reformat.fasta error.fasta OUTPUT
	done
	rm chosen_alignments.fasta
done

unix2dos $format_output_file 2> /dev/null

# Generates graph based on output data
./calculateErrorRates.sh $output_file $repititions
