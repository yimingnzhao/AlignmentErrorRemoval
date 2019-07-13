import sys
import os


fasta_file = sys.argv[1];

f = open( fasta_file, "r" );
lines = f.readlines()

all_dash_columns = []
print(len(lines))
print(len(lines[1]))


for i in range(len(lines[1])):
    all_dash = True
    for j in range(1, len(lines), 2):
        if lines[j][i] != '-':
            all_dash = False
            break
    if all_dash:
        all_dash_columns.append(i)


print(all_dash_columns)
f.close()

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
