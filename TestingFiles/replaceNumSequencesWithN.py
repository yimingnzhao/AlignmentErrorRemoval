import os
import sys


USAGE = "python replaceNumSequencesWithN.py [format file for num error sequences]"

f = open(sys.argv[1], "r")


t = f.readlines()

f.close()

for i in range(len(t)):
    a = t[i].split()
    s = ""
    for j in a:
        s += j + "\t"
    s = s[:-1]
    t[i] = s


for count in range(len(t)):
    a = int(t[count].split("\t")[1].split(":")[1])
    if a == 5 or a == 10 or a == 20 or a == 50:
        t[count] = t[count] + "\n"
        continue
    b = t[count].split("\t")
    string = ""
    string += b[0] + "\t" + b[1].split(":")[0] + ":N" + "\t" + b[2] + "\t" + b[3] + "\t" + b[4] + "\t" + b[5] + "\t" + b[6] + "\n"
    t[count] = string



t = "".join(t)

q = open("FORMAT_REPLACE_N", "w")
q.write(t)
q.close()

