import sys
import os


fasta_file = sys.argv[1];

f = open( fasta_file, "r" );
lines = f.readlines()

all_dash_columns = []
print("Number of sequences: " +  str(len(lines)/2)) 
print("Chars in sequence: " + str(len(lines[1])))


for i in range(len(lines[1])):
    all_dash = True
    for j in range(1, len(lines), 2):
        if lines[j][i] != '-':
            all_dash = False
            break
    if all_dash:
        all_dash_columns.append(i)


f.close()

print("Columns removed: " + str(len(all_dash_columns)))

f = open("removed_dash_output", "a");
for line in lines:
    if ( len(line) < len(lines[1]) ):
        f.write(line);
        continue
    string = line;
    for column in reversed(all_dash_columns):
        string = string[:column] + string[column+1:];
    f.write(string)

f.close();
