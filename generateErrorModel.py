import random
import sys
import os

RNA_DATA = ["A", "U", "G", "C"];


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

Return:
    int: the last possible index of the sequence to begin the error sequence of a given length
"""
def getLastCharInRange( sequence, length ):
    char_count = 0;
    current_index = len(sequence) - 2;
    while char_count < length:
        # Checks if current_index has become negative and exits program if true
        if current_index < 0:
            print("Error: Cannot generate error sequence as error length is greater than the valid sequence length" );
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

Return:
    str: modified sequence with errors
"""
def setErrSequence( sequence, length ):
    current_pos = random.randint( 0, getLastCharInRange(sequence, length) );
    count = 0;
    while count < length:
        if not sequence[current_pos] == "-":
            count += 1;
            rand_segment = RNA_DATA[ random.randint( 0, len( RNA_DATA ) - 1 ) ];
            sequence = sequence[0:current_pos] + rand_segment + sequence[(current_pos + 1):];
        current_pos += 1;
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
USAGE = "python generateErrorModel.py [data file] [num of erroneous alignments] [length of sequence error]"
if not len(sys.argv) == 4:
    print();
    print("\tError: Incorrect number of parameters");
    print("\tUSAGE: " + USAGE );
    sys.exit();
data_file = sys.argv[1];
num_erroneous_alignments = sys.argv[2];
sequence_error_len = sys.argv[3];
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
num_erroneous_alignments = int(num_erroneous_alignments);
sequence_error_len = int(sequence_error_len);
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

# Creates file with alignment sequence errors
f = open( reformat_file, "r" );
error_f = open( error_file, "a" );
sequence_errs = getErrSequences( num_erroneous_alignments, num_alignments );
count = 0;
with open( reformat_file, "r" ) as file_object:
    for line in file_object:
        if isBeginAlignment( line ):
            error_f.write(line);
            count += 1;
            continue;
        if len(sequence_errs) > 0 and sequence_errs[-1] == count:
            error_f.write( setErrSequence( line, sequence_error_len ) );
            sequence_errs.pop();
        else:
            error_f.write( line );
f.close();
error_f.close();
addNewlineToEOF(reformat_file);
addNewlineToEOF(error_file);
