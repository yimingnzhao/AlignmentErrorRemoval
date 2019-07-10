#!/bin/bash

USAGE="./generateGraph_NumErrAlns.sh [path_to_aln_file] [repititions]"
DESCRIPTION="Gets error data for AlignmentErrorRemoval by varying the number of erroneous alignments\n\t\t\tThe number of erroneous alignments will be divisors of n, the total number of alignments. The number of error alignments are [n/n, n/50, n/20, n/10, n/5]\n\t\t\tThe value of k is set to 11\n\t\t\tThe length of an error is set at 88 (8*k)\n\t\t\tThe number of alignments, n, is set to 200"
# Checks parameters
if [ $# -ne 2 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	echo
	echo -e "\tDescription:\t""$DESCRIPTION"
	exit 1
fi

number_of_alignments=200
len_of_err_multiplier=8
value_of_k=11
num_err_aln_divisor_arr=($number_of_alignments 50 20 10 5)
aln_file=$1
repititions=$2

output_file="DATA_OUTPUT"
format_output_file="FORMATTED_OUTPUT"
> $output_file
> $format_output_file
echo -e "$aln_file\terroneous_alignments_num_divisor\trepititions:$repititions\tFP\tFN\tTP\tTN" > $format_output_file

# Loops through the number of alignment divisors array and then the number of repititions for each divisor
for (( i=0; i<${#num_err_aln_divisor_arr[@]}; i++ )); do
	num_err_aln_divisor=${num_err_aln_divisor_arr[$i]}
	echo "Choosing alignments from $aln_file for the number of error alignments divisor $num_err_aln_divisor..."
	python chooseAlignments.py $aln_file $number_of_alignments
	for (( j=0; j<$repititions; j++ )); do
		description="$aln_file\terroneous_alignments_num_divisor:$num_err_aln_divisor\trepitition:$j"
		echo "Generating error model for the number of error alignments divisor $num_err_aln_divisor, repitition $j..."
		python generateErrorModel.py chosen_alignments.fasta $(($number_of_alignments / $num_err_aln_divisor)) $(($value_of_k * $len_of_err_multiplier))
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

