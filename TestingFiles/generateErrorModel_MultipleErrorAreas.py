import random
import sys
import os

RNA_DATA = ["A", "U", "G", "C"];
DNA_DATA = ["A", "T", "G", "C"];

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
Checks if line is the beginning of an alignment

Args: 
    line (str): the line to check

Return:
    bool: whether the string is the beginning of an alignment
"""
def isBeginAlignment( line ):
    if len( line.split(">") ) > 1:
        return True
    return False


"""
Generates the alignment to a single line

Args:
    path (str): the path of the file to read
    new_file (str): the file name of the reformatted file

Return:
    void
"""
def reformatFile( path, new_file ):
    f = open( path, "r" );
    result_f = open( new_file, "a" );
    current_line = f.readline();
    while current_line:
        if isBeginAlignment( current_line ):
            result_f.write( current_line );
        else:
            result_f.write( current_line[:-1] );
        current_line = f.readline();
        if isBeginAlignment( current_line ):
            result_f.write( "\n" );

    f.close();
    result_f.close();

    
"""
Uniformly chooses the alignments to contain errors

Args:
    length (int): the number of erroneous alignments
    size (int): the total number of alignments

Return:
    list: list of sequence indices to modify
"""
def getErrSequences( length, size ):
    sequence_errs = []
    for i in range( length ):
        while True:
            rand_seq_idx = random.randint( 1, size );
            if not rand_seq_idx in sequence_errs:
                sequence_errs.append( rand_seq_idx );
                break;
    sequence_errs.sort( reverse=True );
    return sequence_errs


"""
Gets the last possible char in range to randomly choose the start position of an error sequence
Skips over gaps ("-")

Args: 
    sequence (str): the sequence to modify
    length (int): the number of characters to modify
    divisor (int): the amount to split the sequence
    min_char (int): the character to intially start the error sequence
    repitition (int): the iteration of running this method per sequence
    error_file (file): the file to write to (used in error cases)
    file_name (string): the name of the error file

Return:
    int: the last possible index of the sequence to begin the error sequence of a given length
"""
def getLastCharInRange( sequence, length, divisor, min_char, repitition, error_file, file_name ):
    char_count = 0;
    current_index = int((len(sequence) - 2) / divisor) * repitition;
    while char_count < length:
        # Checks if current_index has become negative and exits program if true
        if current_index < min_char:
            print("Error: Cannot generate error sequence as error length is greater than the valid sequence length" );
            # Closes the error file, and clears its contents
            error_file.close();
            open( file_name, "w" ).close();
            sys.exit();
        current_char = sequence[current_index];
        # Only increments char_count if the char is not a gap
        if not current_char == "-":
            char_count += 1;
        current_index -= 1;
    return current_index + 1;


"""
Uniformly chooses the start position of error under the following conditions:
    - given a set length of the error
    - randomly chooses start position
    - randomly chooses the sequence character

Args:
    sequence (str): the sequence to modify
    length (int): the number of characters to modify
    num_error_areas(int): the number of erroneous areas
    data (list): list of possible data characters
    error_file (file): the file to write to (used in error cases)
    file_name (string): the name of the error file

Return:
    str: modified sequence with errors
"""
def setErrSequence( sequence, length, num_error_areas, data, error_file, file_name ):
    max_pos = getLastCharInRange( sequence, length, num_error_areas, 0, 1, error_file, file_name );
    min_pos = 0;



    for i in range(num_error_areas):
        current_pos = random.randint( min_pos, max_pos );
        count = 0;
        while count < length:
            if not sequence[current_pos] == "-":
                count += 1;
                rand_segment = data[ random.randint( 0, len( data ) - 1 ) ];
                sequence = sequence[0:current_pos] + rand_segment + sequence[(current_pos + 1):];
            current_pos += 1;
        if not i == num_error_areas - 1:
            min_pos = max_pos;
            max_pos = getLastCharInRange( sequence, length, num_error_areas, current_pos, i + 2, error_file, file_name);
    return sequence;


"""
Checks if the last char is a newline and adds a newline if not

Args:
    path (str): the path to the file

Return:
    void
"""
def addNewlineToEOF( path ):
    with open(path, 'r+') as f:
        f.seek(0, os.SEEK_END)  # go at the end of the file
        f.seek(f.tell() - 1, os.SEEK_SET);
        if f.read(1) != '\n':
            # add missing newline if not already present
            f.write('\n')
            f.flush()
            f.seek(0)


# The dataset file
USAGE = "python generateErrorModel_MultipleErrorAreas.py [data file] [num of erroneous sequences] [length of sequence error] [num error areas per sequence] [DNA/RNA]"
if not len(sys.argv) == 6:
    print();
    print("\tError: Incorrect number of parameters");
    print("\tUSAGE: " + USAGE );
    sys.exit();
data_file = sys.argv[1];
num_erroneous_alignments = sys.argv[2];
sequence_error_len = sys.argv[3];
num_error_areas = sys.argv[4];
data_type = sys.argv[5];
if not isInt( num_erroneous_alignments ):
    print();
    print("\tError: Invalid parameter for [num of errneous alignments]");
    print("\tUSAGE: " + USAGE);
    sys.exit();
if not isInt( sequence_error_len ):
    print();
    print("\tError: Invalid parameter for [length of sequence error]");
    print("\tUsage: " + USAGE);
    sys.exit();
if not isInt( num_error_areas ):
    print();
    print("\tError: Invalid parameter for [num_error_areas]");
    print("\tUsage: " + USAGE);
    sys.exit();

num_erroneous_alignments = int(num_erroneous_alignments);
sequence_error_len = int(sequence_error_len);
num_error_areas = int(num_error_areas);
reformat_file = "reformat.fasta";
error_file= "error.fasta";




# Creates a reformated file
reformatFile( data_file, reformat_file );

# Gets data about reformatted alignment file
num_alignments = 0;
chars_in_alignment = 0;
with open( reformat_file, "r" ) as file_object:
    for line in file_object:
        if line[0] == ">":
            continue;
        if chars_in_alignment == 0:
            chars_in_alignment = len( line );
        num_alignments += 1;
sys.stderr.write("Number of Alignments: " + str(num_alignments) + "\n");
sys.stderr.write("Chars in Alignment: " + str(chars_in_alignment) + "\n");

if ( num_alignments < num_erroneous_alignments ):
    num_erroneous_alignments = num_alignments;

# Creates file with alignment sequence errors
f = open( reformat_file, "r" );
error_f = open( error_file, "a" );
sequence_errs = getErrSequences( num_erroneous_alignments, num_alignments );
count = 0;
if  data_type == "RNA":
    data_type = RNA_DATA
else:
    data_type = DNA_DATA
with open( reformat_file, "r" ) as file_object:
    for line in file_object:
        if isBeginAlignment( line ):
            error_f.write(line);
            count += 1;
            continue;
        if len(sequence_errs) > 0 and sequence_errs[-1] == count:
            error_f.write( setErrSequence( line, sequence_error_len, num_error_areas, data_type, error_f, error_file ) );
            sequence_errs.pop();
        else:
            error_f.write( line );
f.close();
error_f.close();
addNewlineToEOF(reformat_file);
addNewlineToEOF(error_file);
