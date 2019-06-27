#!/bin/bash

USAGE="./calculateErrorRates [data file] [number of repetitions per test]"

# Checks for command line arguments
if [ "$#" -ne 2 ]; then
	echo $#
	echo -e "\tError: Invalid number of arguments"
	echo -e "\tUSAGE: $USAGE"
	exit 1
fi

# Gets the error rate values from the input file
echo "Getting error rate values from the input file..."
fp_arr=($(grep FP "$1" | tr -d "FP: "))
fn_arr=($(grep FN "$1" | tr -d "FN: "))
tp_arr=($(grep TP "$1" | tr -d "TP: "))
tn_arr=($(grep TN "$1" | tr -d "TN: "))

# Checks if all arrays are the same length
if [ ${#fp_arr[@]} -ne ${#fn_arr[@]} ] || [ ${#fn_arr[@]} -ne ${#tp_arr[@]} ] || [ ${#tp_arr[@]} -ne ${#tn_arr[@]} ] || [ ${#tn_arr[@]} -ne ${#fp_arr[@]} ]; then
	echo -e "\tError: The error rate counts do not match"
	echo -e "\tUSAGE: $USAGE"
	exit 1
fi

# Loops through the arrays to get averages
echo "Calculating average rate values..."
fp_results=()
fn_results=()
tp_results=()
tn_results=()
count=0
fp_count=0
tp_count=0
fn_count=0
tn_count=0
for (( i=0; i<${#fp_arr[@]}; i++ )); do
	fp_count=`echo "print(int($fp_count + ${fp_arr[$i]}))" | python`
	fn_count=`echo "print(int($fn_count + ${fn_arr[$i]}))" | python`
	tp_count=`echo "print(int($tp_count + ${tp_arr[$i]}))" | python`
	tn_count=`echo "print(int($tn_count + ${tn_arr[$i]}))" | python`
	count=$(( $count + 1 ))

	if [ $count == $2 ]; then
		count=0
		fp_count=`echo "print($fp_count / $2)" | python`
		fn_count=`echo "print($fn_count / $2)" | python`
		tp_count=`echo "print($tp_count / $2)" | python`
		tn_count=`echo "print($tn_count / $2)" | python`
		fp_results+=($fp_count)
		fn_results+=($fn_count)
		tp_results+=($tp_count)
		tn_results+=($tn_count)
		fp_count=0
		tp_count=0
		fn_count=0
		tn_count=0
	fi
done

# Calculates FPR and FNR
echo "Calculating false positive and false negative rates..."
FPR_arr=(0)
FNR_arr=(0)
for ((i=0; i<${#fp_results[@]}; i++ )); do
	FP=`echo "print( (${fp_results[$i]}) / (${fp_results[$i]} + ${tn_results[$i]}) )" | python`
	FN=`echo "print( (${fn_results[$i]}) / (${tp_results[$i]} + ${fn_results[$i]}) )" | python`
	FPR_arr+=($FP)
	FNR_arr+=($FN)
done

FPR_arr+=(1)
FNR_arr+=(1)

FPR_str=""
FNR_str=""

for i in ${FPR_arr[@]}; do
	FPR_str="$FPR_str $i"
done

for i in ${FNR_arr[@]}; do
	FNR_str="$FNR_str $i"
done


python plotROC.py "$FPR_str" "$FNR_str"
