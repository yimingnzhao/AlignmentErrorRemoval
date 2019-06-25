import sys

USAGE = "python organizeData.py [data file]"

if not len(sys.argv) == 2:
    print();
    print("\tIncorrect Parameters");
    print("\t" + USAGE);
    sys.exit();

data_f = open( sys.argv[1], "r" );
output_f = open( "ORGANIZED_DATA", "a" );

current_line = data_f.readline();
count = 0;
data = "";
while current_line:
    if current_line[0] == "\\":
        current_line = data_f.readline();
        continue;
    if current_line[0] == ".":
        output_f.write( "\n\n" );
        output_f.write( current_line );
        output_f.write( "FP\tFN\tTP\tTN\n" );
        current_line = data_f.readline();
        continue;
    if count == 4:
        output_f.write( data + "\n" );
        count = 0;
        data = "";
        current_line = data_f.readline();
        continue;
    count = count + 1;
    data += ( current_line[4:-1] + "\t" );
    current_line = data_f.readline();
data_f.close();
output_f.close();

