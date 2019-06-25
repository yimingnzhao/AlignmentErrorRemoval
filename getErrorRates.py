import sys


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
Gets the FP, FN, TP, and TN of the current line

Args:
    correct (str): the line from the correct file
    error   (str): the line from the error file
    output  (str): the line from the output file

Return:
    tuple: tuple of (fp, fn, tp, tn)

"""
def getLineErrorRates( correct, error, output ):
    fp = 0;
    fn = 0;
    tp = 0;
    tn = 0;
    for x in range( len(correct) ):
        output_char = output[x];
        error_char = error[x];
        correct_char = correct[x];
        if output_char == 'X':
            if not error_char == correct_char:
                tp = tp + 1;
            else:
                fp = fp + 1;
        else:
            if not output_char == correct_char:
                fn = fn + 1;
            else:
                tn = tn + 1;
    return (fp, fn, tp, tn);
        


USAGE = "python getErrorRates.py [correct file] [error file] [correction output file]"

if not len(sys.argv) == 4:
    print();
    print("\tIncorrect Parameters");
    print("\tUSAGE: " + USAGE);
    sys.exit();

correct = sys.argv[1];
error = sys.argv[2]
output = sys.argv[3];

correct_f = open( correct, "r" );
error_f = open( error, "r" );
output_f = open( output, "r" );

false_positive = 0;
false_negative = 0;
true_positive = 0;
true_negative = 0;
correct_line = correct_f.readline();
output_line = output_f.readline();
error_line = error_f.readline();
while correct_line:
    line_stats = getLineErrorRates( correct_line, error_line, output_line );
    false_positive += line_stats[0];
    false_negative += line_stats[1];
    true_positive += line_stats[2];
    true_negative += line_stats[3]
    correct_line = correct_f.readline();
    error_line = error_f.readline();
    output_line = output_f.readline();

correct_f.close();
error_f.close();
output_f.close();

print("FP: " + str(false_positive));
print("FN: " + str(false_negative));
print("TP: " + str(true_positive));
print("TN: " + str(true_negative));


