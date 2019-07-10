#!/bin/bash

output_dir=generatedFiles_AllTests

if [ -d $output_dir ]; then
	rm -rf $output_dir
fi
mkdir $output_dir

default_k=11
k_vals=(7 11 15)
default_num_err_aln=50
num_err_aln_vals=(1 10 50 100 200)
default_err_len_multiplier=8
err_len_multiplier_vals=(1.5 2 8 32 64)
default_choose_num_aln=500

# Tests with variable error length
output_file="OUTPUT_ERR_LEN"
echo > $output_file
echo "Variable Error Length" >> $output_file
echo >> $output_file
echo "Now running tests with variable error length..."

for i in "${err_len_multiplier_vals[@]}"; do
	echo "$i Error Length" >> $output_file
	for subdir in ./10000/*; do
		echo "$subdir" >> $output_file
		python chooseAlignments.py "$subdir/model/true.fasta" $default_choose_num_aln
		for (( j=0; j<10; j++ )); do
			echo "Running $subdir, Test No. $j..."
			python generateErrorModel.py RNASim_$default_choose_num_aln.fasta $default_num_err_aln `echo "print(int($i*$default_k))" | python ` 2> /dev/null
			julia correction.jl -k $default_k -m X -a N error.fasta > OUTPUT 2> /dev/null
			python getErrorRates.py reformat.fasta error.fasta OUTPUT >> $output_file
			mv reformat.fasta "./"$output_dir"/reformat_"${subdir:8}"_ErrLen"$i"_"$j".fasta"
			mv error.fasta "./"$output_dir"/error_"${subdir:8}"_ErrLen"$i"_"$j".fasta"
			mv OUTPUT "./"$output_dir"/output_"${subdir:8}"_ErrLen"$i"_"$j".fasta"
		done
	done
	mv RNASim_$default_choose_num_aln.fasta "./"$output_dir"/RNA_Sim_"${subdir:8}".fasta"
done
echo "Completed running tests with variable error length"
echo
echo


# Tests with variable number of error alignments
output_file="OUTPUT_ERR_ALN"
echo > $output_file
echo "Variable Error Alignments" >> $output_file
echo >> $output_file
echo "Now running tests with variable error alignments..."
for i in "${num_err_aln_vals[@]}"; do
	echo "$i Error Alignments" >> $output_file
	for subdir in ./10000/*; do
		echo "$subdir" >> $output_file
		python chooseAlignments.py "$subdir/model/true.fasta" $default_choose_num_aln
		for (( j=0; j<10; j++ )); do
			echo "Running $subdir, Test No. $j..."
			python generateErrorModel.py RNASim_$default_choose_num_aln.fasta $i `echo "print(int($default_err_len_multiplier*$default_k))" | python ` 2> /dev/null
			julia correction.jl -k $default_k -m X -a N error.fasta > OUTPUT 2> /dev/null
			python getErrorRates.py reformat.fasta error.fasta OUTPUT >> $output_file
			mv reformat.fasta "./"$output_dir"/reformat_"${subdir:8}"_ErrAln"$i"_"$j".fasta"
			mv error.fasta "./"$output_dir"/error_"${subdir:8}"_ErrAln"$i"_"$j".fasta"
			mv OUTPUT "./"$output_dir"/output_"${subdir:8}"_ErrAln"$i"_"$j".fasta"
		done
	done
	mv RNASim_$default_choose_num_aln.fasta "./"$output_dir"/RNA_Sim_"${subdir:8}".fasta"
done
echo "Completed running tests with variable error alignments"
echo 
echo


# Tests with variable number of k-mers
output_file="OUTPUT_K"
echo > $output_file
echo "Variable Value of K" >> $output_file
echo >> $output_file
echo "Now running tests with variable values of K..."
for i in "${k_vals[@]}"; do
	echo "$i K Value" >> $output_file
	for subdir in ./10000/*; do
		echo "$subdir" >> $output_file
		python chooseAlignments.py "$subdir/model/true.fasta" $default_choose_num_aln
		for (( j=0; j<10; j++ )); do
			echo "Running $subdir, Test No. $j..."
			python generateErrorModel.py RNASim_$default_choose_num_aln.fasta $i `echo "print(int($default_err_len_multiplier*$i))" | python ` 2> /dev/null
			julia correction.jl -k $i -m X -a N error.fasta > OUTPUT 2> /dev/null
			python getErrorRates.py reformat.fasta error.fasta OUTPUT >> $output_file
			mv reformat.fasta "./"$output_dir"/reformat_"${subdir:8}"_KVal"$i"_"$j".fasta"
			mv error.fasta "./"$output_dir"/error_"${subdir:8}"_KVal"$i"_"$j".fasta"
			mv OUTPUT "./"$output_dir"/output_"${subdir:8}"_KVal"$i"_"$j".fasta"
		done
	done
	mv RNASim_$default_choose_num_aln.fasta "./"$output_dir"/RNA_Sim_"${subdir:8}".fasta"
done
echo "Completed running tests with variable error alignments"
echo 
echo
