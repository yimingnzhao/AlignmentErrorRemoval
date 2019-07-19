import os
import sys


original_file = sys.argv[1];




f = open(original_file, "r");


f1_format = open("diameter0.25-0.3_100000_erralnN_2reps_format", "a");
f2_format = open("diameter0.25-0.3_100000_erraln50_2reps_format", "a");
f3_format = open("diameter0.25-0.3_100000_erraln20_2reps_format", "a");
f4_format = open("diameter0.25-0.3_100000_erraln10_2reps_format", "a");
f5_format = open("diameter0.25-0.3_100000_erraln5_2reps_format", "a");
#
#f1_format = open("diameter0.25-0.3_100000_errlen1_2reps_format", "a");
#f2_format = open("diameter0.25-0.3_100000_errlen1.5_2reps_format", "a");
#f3_format = open("diameter0.25-0.3_100000_errlen2_2reps_format", "a");
#f4_format = open("diameter0.25-0.3_100000_errlen8_2reps_format", "a");
#f5_format = open("diameter0.25-0.3_100000_errlen32_2reps_format", "a");
#f6_format = open("diameter0.25-0.3_100000_errlen64_2reps_format", "a");
line = f.readline()

while line:
    for i in range(2):
        f1_format.write(line)
        line = f.readline()
    for i in range(2):
        f2_format.write(line)
        line = f.readline()
    for i in range(2):
        f3_format.write(line)
        line = f.readline()
    for i in range(2):
        f4_format.write(line)
        line = f.readline()
    for i in range(2):
        f5_format.write(line)
        line = f.readline()
#    for i in range(8):
#        f6_format.write(line)
#        line = f.readline()
#


