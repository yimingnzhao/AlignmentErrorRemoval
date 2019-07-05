#!/bin/bash

opts=":hn:a:e:k:r:"	

USAGE="./generateData_Custom.sh [-n number of alignments to choose] [-a number of erroneous alignments] [-e length of error] [-k value of K] [-r number of repititions] [-h] fasta_file"
DESCRIPTION="Generates data for testing the AlignmentErrorRemoval algorithm\n\n\tPositional Parameters:\n\t\tfasta_file:\tThe path to the fasta file to be tested\n\n\tOptional Parameters:\n\t\t-n\t\tThe total number of alignments to choose from the fasta_file\n\t\t-a\t\tThe number of alignments to insert errors\n\t\t-e\t\tThe length of an error\n\t\t-k\t\tThe value of K\n\t\t-r\t\tThe number of repititions to run\n\t\t-h\t\tPrints the usage statement and exits"

# Default values of options
num_alignments_to_choose=200;
num_error_alignments=20;
len_of_error=88;
value_of_k=11;
repititions=10;

# Sets the values of user inputted optional values
while getopts "$opts" args; do
	case $args in
		n)
			num_alignments_to_choose=$OPTARG
			;;
		a)
			num_error_alignments=$OPTARG
			;;
		e)
			len_of_error=$OPTARG
			;;
		k)	
			value_of_k=$OPTARG
			;;
		r)
			repititions=$OPTARG
			;;
		h | *)
			echo
			echo -e "\t""$USAGE"
			echo
			echo -e "\t""$DESCRIPTION"
			exit 1
			;;
	esac
done

# Shifts the number of positional parameters by OPTIND
shift $(($OPTIND - 1))

# Checks if the option values are still integers
int_regex='^[0-9]+$'

if ! [[ $num_alignments_to_choose =~ $int_regex ]] ; then
   echo "Error: The value for the number of alignments to choose is not a valid integer: $num_alignments_to_choose" >&2
   exit 1
fi

if ! [[ $num_error_alignments =~ $int_regex ]] ; then
   echo "Error: The value for the number of error alignments to choose is not a valid integer: $num_error_alignments" >&2
   exit 1
fi

if ! [[ $len_of_error =~ $int_regex ]] ; then
   echo "Error: The value for the length of error is not a valid integer: $len_of_error" >&2
   exit 1
fi

if ! [[ $value_of_k =~ $int_regex ]] ; then
   echo "Error: The value of K is not a valid integer: $value_of_k" >&2
   exit 1
fi

if ! [[ $repititions =~ $int_regex ]] ; then
   echo "Error: The value for the number of repititions is not a valid integer: $repititions" >&2
   exit 1
fi

# Checks for the correct number of positional parameters
if [ $# -ne 1 ]; then
	echo
	echo "Error: Incorrect number of parameters" >&2
	echo
	echo -e "\t""$USAGE"
	echo 
	echo -e "\t""$DESCRIPTION"
	exit 1
fi

data_file=$1
output_file="DATA_OUTPUT"
formatted_output_file="FORMATTED_OUTPUT"

# Chooses alignments
echo "Choosing alignments..."
python chooseAlignments.py $data_file $num_alignments_to_choose

# Generates an error model
echo "Generating error model..."
python generateErrorModel.py "chosen_alignments.fasta" $num_error_alignments $len_of_error

for (( i=0; i<$repititions; i++ )); do
	description="$data_file\tnum_alignments:$num_alignments_to_choose\tnum_err_aln:$num_error_alignments\terr_len:$len_of_error\tval_of_k:$value_of_k\trepitition:$i"
	echo "Running the correction algorithm, repitition $i"
	julia correction.jl -k $value_of_k -m X -a N error.fasta > OUTPUT 2> /dev/null
	python getErrorRates.py reformat.fasta error.fasta OUTPUT $description >> $output_file 2>> $formatted_output_file
	rm reformat.fasta error.fasta OUTPUT
done

rm chosen_alignments.fasta

unix2dos $formatted_output_file 2> /dev/null

