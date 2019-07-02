#!/bin/bash

USAGE="./generateGraph_ErrLen.sh [path_to_aln_file] [repititions]"
DESCRIPTION="Gets error data for AlignmentErrorRemoval by varying the length of an error\n\t\t\tThe error lengths will be multiples of k (k=11). The error lengths are [1*k, 1.5*k, 2*k, 8*k, 32*k, 64*k]\n\t\t\tThe value of k is set to 11\n\t\t\tThe number of erroneous alignments is n/20, where n is the total number of alignments\n\t\t\tThe number of alignments, n, is set to 200"
# Checks parameters
if [ $# -ne 2 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	echo
	echo -e "\tDescription:\t""$DESCRIPTION"
	exit 1
fi

len_of_err_multiplier_arr=(1 1.5 2 8 32 64)
num_err_aln_divisor=20
value_of_k=11
number_of_alignments=200
aln_file=$1
repititions=$2

output_file="DATA_OUTPUT"
format_output_file="FORMATTED_OUTPUT"
> $output_file
> $format_output_file
echo -e "$aln_file\terror_length_multiplier\trepititions:$repititions\tFP\tFN\tTP\tTN" > $format_output_file

# Loops through the length of errors multiplier array and then the number of repititions for each multiplier
for (( i=0; i<${#len_of_err_multiplier_arr[@]}; i++ )); do
	err_len_multiplier=${len_of_err_multiplier_arr[$i]}
	python chooseAlignments.py $aln_file $number_of_alignments
	for (( j=0; j<$repititions; j++ )); do
		description="$aln_file\terror_length_multipler:$err_len_multiplier\trepitition:$j"
		len_of_err=`awk -v k=$value_of_k -v mult=$err_len_multiplier 'BEGIN { printf("%.0f", k * mult); }'`
		python generateErrorModel.py chosen_alignments.fasta $(($number_of_alignments / $num_err_aln_divisor)) $len_of_err
		julia correction.jl -k $value_of_k -m X -a N error.fasta > OUTPUT
		python getErrorRates.py reformat.fasta error.fasta OUTPUT $description >> $output_file 2>> $format_output_file
		rm reformat.fasta error.fasta OUTPUT
	done
	rm chosen_alignments.fasta
done

unix2dos $format_output_file 

# Generates graph based on output data
./calculateErrorRates.sh $output_file $repititions

