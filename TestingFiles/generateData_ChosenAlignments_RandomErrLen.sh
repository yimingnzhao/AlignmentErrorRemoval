#!/bin/bash


USAGE="./generateData_ChosenAlignments_RandomErrLen.sh [directory with chosen alignment files] [repititions] [data type]"

DESCRIPTION="Gets error data for AlignmentErrorRemoval by varying the length of an error through a directory of alignments of similar diameter\n\t\t\tThe error length for each error sequence will be a random multiple of k in range [2*k, 64*k]\n\t\t\tThe value of k is set to 11\n\t\t\tThe number of erroneous alignments is n/20, where n is the total number of alignments\n\t\t\tThe number of alignments, n, is dependent on the file"

if [ $# -ne 3 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: $USAGE"
	echo 
	echo -e "\t$DESCRIPTION"
	exit 1
fi


num_err_aln_divisor=20
value_of_k=11
number_of_alignments=10000000
repititions=$2
data_type=$3

output_file="DATA_OUTPUT"
format_output_file="FORMATTED_OUTPUT"
> $output_file
> $format_output_file

for file in $1/*; do
	aln_file=$file
	echo "Choosing alignments from $aln_file..."
	python chooseAlignments.py $aln_file $number_of_alignments
	for (( j=0; j<$repititions; j++ )); do
		description="$aln_file\terror_length_multipler:RANDOM\trepitition:$j"
		echo "Generating error model, repitition $j..."
		num_alignments=$((`wc -l < chosen_alignments.fasta` / 2))
		python generateErrorModel_RandomErrLen.py chosen_alignments.fasta $(($num_alignments / $num_err_aln_divisor)) $value_of_k $data_type
		echo "Running the correction algorithm..."
		julia correction.jl -k $value_of_k -m X -a N -n error.fasta > OUTPUT 2> /dev/null
		echo "Getting error rates for the correction algorithm..."
		python getErrorRates.py reformat.fasta error.fasta OUTPUT $description >> $output_file 2>> $format_output_file
		rm reformat.fasta error.fasta OUTPUT
	done
	rm chosen_alignments.fasta
done





unix2dos $format_output_file 2> /dev/null 

