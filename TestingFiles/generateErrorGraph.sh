#!/bin/bash

USAGE="./generateErrorGraph.sh [path_to_aln_file] [path_to_newick_tree] [repititions]"
DESCRIPTION="Gets the error data for AlignmentErrorRemoval with a varying set of independent variables"

if [ $# -ne 3 ]; then
	echo
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	echo
	echo -e "\tDescription:\t""$DESCRIPTION"
	exit 1
fi

aln_file=$1
newick_file=$2
repititions=$3

PS3='Please select the independent condidtion to run the alignment correction algorithm: '
options=("Length of Error" "Number of Erroneous Alignments" "Alignment Diameter Range" "Quit")
echo
select opt in "${options[@]}"
do
	case $opt in
		"Length of Error")
			echo 
			echo "Generating data with varying lengths of error..."
			./generateGraph_ErrLen.sh $aln_file $repititions
			break
			;;
		"Number of Erroneous Alignments")
			echo
			echo "Generating data with varying number of erroenous alignments"
			./generateGraph_NumErrAlns.sh $aln_file $repititions
			break
			;;
		"Alignment Diameter Range")
			echo
			echo "Generating data with varying diameter range"
			./generateGraph_Diameter.sh $aln_file $newick_file $repititions 
			break
			;;
		"Quit")
			break
			;;
		*) echo "Invalid option: $REPLY";;
	esac
done
