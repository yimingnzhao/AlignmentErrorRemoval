import os
import sys


USAGE = "python getDataFromFormat.py [format file] [keyword] [repititions]"


if not len(sys.argv) == 4:
    print("")
    print(len(sys.argv))
    print("\tError: Incorrect number of parameters", flush=True);
    print("")
    print("\tUSAGE: " + USAGE, flush=True)
    print("");
    exit();


format_file = sys.argv[1]
keyword = sys.argv[2]
repititions = int(sys.argv[3])

f = open(format_file, "r")
line = f.readline()

result_str = "";

while line:
    # Split by backslash
    if "/" in line:
        array = line.split("/")
        for index in array:
            if index != array[0] and index != "":
                line = index
                break
    # Split by tab
    if "\t" in line:
        line = line.split("\t")[0]
    # Remove ".fasta"
    if ".fasta" in line:
        line = line.split(".fasta")[0]
    # Get the keyword
    line_arr = line.split("_");
    for arr_index in line_arr:
        if keyword in arr_index:
            result_str += ( arr_index[ arr_index.index(keyword) + len(keyword) : ] + "#" )

    count = 0
    while ( count < repititions ):
        if line:
            line = f.readline()
        count+=1

f.close()
print(result_str);
