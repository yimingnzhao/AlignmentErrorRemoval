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
		fp_count=`echo "print(int($fp_count / $2))" | python`
		fn_count=`echo "print(int($fn_count / $2))" | python`
		tp_count=`echo "print(int($tp_count / $2))" | python`
		tn_count=`echo "print(int($tn_count / $2))" | python`
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

# Calculates error rates
echo "Calculating error rates..."
FPR_arr=(0)
TPR_arr=(0)
recall_arr=(0)
precision_arr=(0)
for ((i=0; i<${#fp_results[@]}; i++ )); do
	FP=`echo -e "try:\n\tprint( (${fp_results[$i]}) / (${fp_results[$i]} + ${tn_results[$i]}) )\nexcept ZeroDivisionError:\n\tprint(0)" | python`
	TP=`echo -e "try:\n\tprint( (${tp_results[$i]}) / (${tp_results[$i]} + ${fn_results[$i]}) )\nexcept ZeroDivisionError:\n\tprint(0)" | python`
	recall=`echo -e "try:\n\tprint( (${tp_results[$i]}) / (${tp_results[$i]} + ${fn_results[$i]}) )\nexcept ZeroDivisionError:\n\tprint(0)" | python`
	precision=`echo -e "try:\n\tprint( (${tp_results[$i]}) / (${tp_results[$i]} + ${fp_results[$i]}) )\nexcept ZeroDivisionError:\n\tprint(0)" | python`	
	FPR_arr+=($FP)
	TPR_arr+=($TP)
	recall_arr+=($recall)
	precision_arr+=($precision)
done

FPR_arr+=(1)
TPR_arr+=(1)
recall_arr+=(1)
precision_arr+=(1)

FPR_str=""
TPR_str=""
recall_str=""
precision_str=""

for i in ${FPR_arr[@]}; do
	FPR_str="$FPR_str $i"
done

for i in ${TPR_arr[@]}; do
	TPR_str="$TPR_str $i"
done

for i in ${recall_arr[@]}; do
	recall_str="$recall_str $i"
done

for i in ${precision_arr[@]}; do
	precision_str="$precision_str $i"
done


echo "FPR: $FPR_str"
echo "TPR: $TPR_str"
echo "Recall: $recall_str"
echo "Precision: $precision_str"

python plotROC.py "$FPR_str" "$TPR_str"