#!/bin/bash

USAGE="./generateGraph_Diameter.sh [path_to_aln_file] [path_to_newick_file] [repititions]"

# Checks parameters
if [ $# -ne 3 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	exit 1
fi

diameter_ranges=(0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.70)
num_err_aln_divisor=10
len_of_err_multiplier=8
value_of_k=11
aln_file=$1
newick_file=$2
repititions=$3

output_file="DATA_OUTPUT"
> $output_file

# Loops through the diameter ranges and then the number of repititions for each range
for (( i=0; i<${#diameter_ranges[@]}-1; i++ )); do
	min_diameter=${diameter_ranges[$i]}
	max_diameter=${diameter_ranges[$(($i+1))]}
	python chooseAlignmentsByDistance.py $newick_file $aln_file $min_diameter $max_diameter
	for (( j=0; j<$repititions; j++ )); do
		num_alignments=$((`wc -l < chosen_alignments.fasta` / 2))
		python generateErrorModel.py chosen_alignments.fasta $(($num_alignments / $num_err_aln_divisor)) $(($value_of_k * $len_of_err_multiplier))
		julia correction.jl -k $value_of_k -m X -a N error.fasta > OUTPUT
		python getErrorRates.py reformat.fasta error.fasta OUTPUT >> $output_file
		rm reformat.fasta error.fasta OUTPUT
	done
	rm chosen_alignments.fasta
done

# Generates graph based on output data
./calculateErrorRates.sh $output_file $repititions

