import os
import sys


original_file = sys.argv[1];




f = open(original_file, "r");
f1_format = open("diameter0.15-0.2_100000_erralnN_2reps_data", "a");
f2_format = open("diameter0.15-0.2_100000_erraln50_2reps_data", "a");
f3_format = open("diameter0.15-0.2_100000_erraln20_2reps_data", "a");
f4_format = open("diameter0.15-0.2_100000_erraln10_2reps_data", "a");
f5_format = open("diameter0.15-0.2_100000_erraln5_2reps_data", "a");
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


