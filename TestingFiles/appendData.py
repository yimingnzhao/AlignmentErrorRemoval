import os
import sys



def skip_lines( f, lines ):
    line = ""
    for i in range(lines):
        line = f.readline()
    return line



USAGE = "python appendData.py [data file append] [format file append] [data to append] [format to append] [query to append] [num lines after query to appnd] [num lines from format to append]"

format_to_data = 4


if len(sys.argv) != 8:
    print("", flush=True)
    print("\tError: Incorrect number of parameters", flush=True)
    print()
    print("\tUSAGE: " + USAGE, flush=True)
    exit()

append_data = open(sys.argv[1], "r")
append_format = open(sys.argv[2], "r")
src_data = open(sys.argv[3], "r")
src_format = open(sys.argv[4], "r")
query = sys.argv[5]
lines_after_query = int(sys.argv[6])
lines_to_append = int(sys.argv[7])


append_data_lines = append_data.readlines()
append_format_lines = append_format.readlines()
src_data_line = src_data.readline()
src_format_line = src_format.readline()
append_data.close()
append_format.close()



format_index = 0
data_index = 0

while src_format_line and format_index < len(append_format_lines):
    if query in append_format_lines[ format_index ]:
        for i in range(lines_after_query):
            format_index += 1
            data_index += format_to_data
        for i in range(lines_to_append):
            append_format_lines.insert( format_index, src_format_line )
            src_format_line = src_format.readline()
            format_index += 1
            for j in range(format_to_data):
                append_data_lines.insert( data_index, src_data_line )
                src_data_line = src_data.readline()
                data_index += 1
    else:
        format_index += 1
        data_index += format_to_data



src_data.close()
src_format.close()




print(append_format_lines)

append_data = open( sys.argv[1], "w" )
append_format = open( sys.argv[2], "w" )

print("Joining Data Lines...", flush=True)
append_data_lines = "".join( append_data_lines )
print("Joining Format Lines...", flush=True)
append_format_lines = "".join( append_format_lines )

print("Writing Data Lines...", flush=True)
append_data.write( append_data_lines )
print("Writing Format Lines...", flush=True)
for i in append_format_lines:
    append_format.write(i)
append_data.close()
append_format.close()

