#!/bin/bash

touch DATA_OUTPUT
mkdir generatedFiles
# Loops through all subdirectories in 1000 
for subdir in ./10000/*; do
	echo "$subdir" >> DATA_OUTPUT
	python chooseAlignments.py "$subdir/model/true.fasta" 200
	for (( i=0; i<10; i++ )); do
		echo "Running $subdir test number $i..."
		python generateErrorModel.py RNASim_200.fasta 50 88
		julia correction.jl -k 11 -m X -a N error.fasta > OUTPUT
		python getErrorRates.py reformat.fasta error.fasta OUTPUT >> DATA_OUTPUT
		mv reformat.fasta "./generatedFiles/reformat_"${subdir:8}"_"$i".fasta"
		mv error.fasta "./generatedFiles/error_"${subdir:8}"_"$i".fasta"
		mv OUTPUT "./generatedFiles/OUTPUT_"${subdir:8}"_"$i".fasta"
		echo >> DATA_OUTPUT
	done
	echo >> DATA_OUTPUT
	echo >> DATA_OUTPUT
	mv RNASim_200.fasta "./generatedFiles/RNA_Sim_"${subdir:8}".fasta"
done
