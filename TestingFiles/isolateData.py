import sys
import os



USAGE = "python isolateData.py [data file] [format file] [query]"

if len(sys.argv) != 4:
    print("", flush=True)
    print("\tError: Incorrect number of parameters", flush=True)
    print();
    print("\tUSAGE: " + USAGE, flush=True)
    exit()


f_data = open( sys.argv[1], "r")
f_format = open( sys.argv[2], "r")
query = sys.argv[3]

output_data = open("NEW_DATA", "a")
output_format = open("NEW_FORMAT", "a")

data_line = f_data.readline()
format_line = f_format.readline()
while format_line:
    if query in format_line:
        output_format.write(format_line)
        for i in range(4):
            output_data.write(data_line)
            data_line = f_data.readline()
    else:
        for i in range(4):
            data_line = f_data.readline()
    format_line = f_format.readline()



f_data.close()
f_format.close()
output_format.close()
output_data.close()
