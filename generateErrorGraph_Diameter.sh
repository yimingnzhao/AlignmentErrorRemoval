#!/bin/bash

USAGE="./generateErrorGraph_Diameter.sh path_to_aln_file path_to_newick_file"

# Checks parameters
if [ $# -ne 2 ]; then
	echo -e "\tError: Incorrect number of parameters"
	echo -e "\tUSAGE: ""$USAGE"
	exit 1
fi

diameter_ranges=(0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65)
max_diameter=0.7


