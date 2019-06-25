#!/bin/bash

touch DATA_OUTPUT
# Loops through all subdirectories in 1000S5 
for subdir in ./1000S5/*; do
	echo $subdir >> DATA_OUTPUT
	# Runs each each rose.aln.true.fasta file correction 20 times
	for (( i=0; i<20; i++ )); do
		python generateErrorModel.py "$subdir/rose.aln.true.fasta"
		dos2unix error.fasta
		julia correction.jl -k 15 -m X -a N error.fasta > OUTPUT
		python getErrorRates.py reformat.fasta error.fasta OUTPUT >> DATA_OUTPUT
		rm *.fasta
		rm OUTPUT
	done
	echo >> DATA_OUTPUT
done
