import random
import sys


"""
Checks if an input string is an integer

Args:
    num (str): the string to check

Return:
    bool: whether the string is an int or not
"""
def isInt( num ):
    try:
        int(num);
        return True;
    except ValueError:
        return False;


"""
Gets the number of alignments in the file

Args:
    path (str): the path of the file to read

Return:
    int: the number of alignments in the file 
"""
def getAlignmentsInFile( path ):
    count = 0;
    for line in open( path ):
        if ">" in line:
            count += 1;
    return count;

    
"""
Uniformly chooses alignments

Args:
    count (int): the number of alignments to choose
    size (int): the size of the file

Return:
    list: list that specifies which indices should be chosen
"""
def getRandomAlignmentIndices( count, size ):
    indices = [];
    for i in range( count ):
        while True:
            rand_index = random.randint( 1, size );
            if not rand_index in indices:
                indices.append( rand_index );
                break;
    indices.sort( reverse=True );
    return indices;



USAGE = "python chooseAlignments.py [data file] [num of alignments to choose]"
if not len(sys.argv) == 3:
    print();
    print("\tError: Incorrect number of parameters");
    print("\tUSAGE: " + USAGE);
    sys.exit();
if not isInt(sys.argv[2]):
    print();
    print("\tError: Invalid parameter for [num of alignments to choose]");
    print("\tUSAGE: " + USAGE);
    sys.exit();

print("Getting random alignments...", flush=True )
file_size = getAlignmentsInFile(sys.argv[1]);


# if alignments to choose > alignments in file, then all alignments are chosen
if file_size < int(sys.argv[2]):
    f = open( sys.argv[1], "r" )
    result_f = open( "chosen_alignments.fasta", "a" )
    line = f.readline()
    while line:
        result_f.write(line)
        line = f.readline()
    f.close()
    result_f.close()
    sys.exit()

indices = getRandomAlignmentIndices( int(sys.argv[2]), file_size );
f = open( sys.argv[1], "r" );
result_f = open( "chosen_alignments.fasta", "a" );
count = 1;
while len(indices) > 0:
    data = f.readline() + f.readline();
    if indices[-1] == count:
        result_f.write( data );
        indices.pop();
    count += 1;
f.close();
result_f.close();


    
