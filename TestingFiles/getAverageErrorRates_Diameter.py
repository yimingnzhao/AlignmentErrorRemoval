import sys
import os


USAGE = "python getAverageErrorRates_Diameter.py [format file] [variable]"


if len(sys.argv) != 3:
    print("", flush=True)
    print("\tError: Incorrect number of parameters", flush=True)
    print()
    print("\tUSAGE: " + USAGE)
    exit()


keyword = "diameter"
variable = sys.argv[2]

diameter05 = {0 : 0, -1 : 0}
diameter10 = {0 : 0, -1 : 0}
diameter15 = {0 : 0, -1 : 0}
diameter20 = {0 : 0, -1 : 0}
diameter25 = {0 : 0, -1 : 0}
diameter30 = {0 : 0, -1 : 0}
diameter35 = {0 : 0, -1 : 0}
diameter40 = {0 : 0, -1 : 0}



f = open(sys.argv[1], "r")

line = f.readline()


while line:
    
    diameter = 0

    data_var = 0

    FP = 0
    FN = 0
    TP = 0
    TN = 0


    # Split by backslash
    if "/" in line:
        array = line.split("/")
        for index in array:
            if index != array[0] and index != "":
                line = index
                break
    # Removes all whitespace and inserts tabs
    components = line.split()
    line = ""
    for i in (components):
        line += i + "\t"
    line = line[:-1]
    # Split by tab
    if "\t" in line:
        temp = line.split("\t")
        line = temp[0]
        data_var = (temp[1].split(":")[1])
        if data_var == "N":
            data_var = -10
        else:
            data_var = float(data_var)
        FP = int(temp[3])
        FN = int(temp[4])
        TP = int(temp[5])
        TN = int(temp[6])
        
    # Remove ".fasta"
    if ".fasta" in line:
        line = line.split(".fasta")[0]
    # Get the keyword
    line_arr = line.split("_");
    for arr_index in line_arr:
        if keyword in arr_index:
            diameter = float( arr_index[ arr_index.index(keyword) + len(keyword) : ] )
            break

    

    if diameter < 0.05:
        diameter05[0]+=1
        diameter05[-1]+=diameter
        if not data_var in diameter05:
            diameter05[data_var] = [0, 0, 0, 0]
        diameter05[data_var][0] += FP 
        diameter05[data_var][1] += FN
        diameter05[data_var][2] += TP
        diameter05[data_var][3] += TN

    elif diameter < 0.1:
        diameter10[0]+=1
        diameter10[-1]+=diameter
        if not data_var in diameter10:
            diameter10[data_var] = [0, 0, 0, 0]
        diameter10[data_var][0] += FP 
        diameter10[data_var][1] += FN
        diameter10[data_var][2] += TP
        diameter10[data_var][3] += TN

    elif diameter < 0.15:
        diameter15[0]+=1;
        diameter15[-1]+=diameter
        if not data_var in diameter15:
            diameter15[data_var] = [0, 0, 0, 0]
        diameter15[data_var][0] += FP 
        diameter15[data_var][1] += FN
        diameter15[data_var][2] += TP
        diameter15[data_var][3] += TN

    elif diameter < 0.2:
        diameter20[0]+=1;
        diameter20[-1]+=diameter
        if not data_var in diameter20:
            diameter20[data_var] = [0, 0, 0, 0]
        diameter20[data_var][0] += FP 
        diameter20[data_var][1] += FN
        diameter20[data_var][2] += TP
        diameter20[data_var][3] += TN

    elif diameter < 0.25:
        diameter25[0]+=1;
        diameter25[-1]+=diameter
        if not data_var in diameter25:
            diameter25[data_var] = [0, 0, 0, 0]
        diameter25[data_var][0] += FP 
        diameter25[data_var][1] += FN
        diameter25[data_var][2] += TP
        diameter25[data_var][3] += TN

    elif diameter < 0.3:
        diameter30[0]+=1;
        diameter30[-1]+=diameter
        if not data_var in diameter30:
            diameter30[data_var] = [0, 0, 0, 0]
        diameter30[data_var][0] += FP 
        diameter30[data_var][1] += FN
        diameter30[data_var][2] += TP
        diameter30[data_var][3] += TN

    elif diameter < 0.35:
        diameter35[0]+=1;
        diameter35[-1]+=diameter
        if not data_var in diameter35:
            diameter35[data_var] = [0, 0, 0, 0]
        diameter35[data_var][0] += FP 
        diameter35[data_var][1] += FN
        diameter35[data_var][2] += TP
        diameter35[data_var][3] += TN
    
    elif diameter < 0.4:
        diameter40[0]+=1;
        diameter40[-1]+=diameter
        if not data_var in diameter40:
            diameter40[data_var] = [0, 0, 0, 0]
        diameter40[data_var][0] += FP 
        diameter40[data_var][1] += FN
        diameter40[data_var][2] += TP
        diameter40[data_var][3] += TN


    line = f.readline()


f.close()


for key in diameter05:
    if key == 0:
        continue
    if key == -1:
        diameter05[-1] = float(diameter05[-1]/diameter05[0])
        continue
    for i in range(4):
        diameter05[key][i] = int(diameter05[key][i] / diameter05[0])

for key in diameter10:
    if key == 0:
        continue
    if key == -1:
        diameter10[-1] = float(diameter10[-1]/diameter10[0])
        continue
    for i in range(4):
        diameter10[key][i] = int(diameter10[key][i] / diameter10[0])

for key in diameter15:
    if key == 0:
        continue
    if key == -1:
        diameter15[-1] = float(diameter15[-1]/diameter15[0])
        continue
    for i in range(4):
        diameter15[key][i] = int(diameter15[key][i] / diameter15[0])

for key in diameter20:
    if key == 0:
        continue
    if key == -1:
        diameter20[-1] = float(diameter20[-1]/diameter20[0])
        continue
    for i in range(4):
        diameter20[key][i] = int(diameter20[key][i] / diameter20[0])

for key in diameter25:
    if key == 0:
        continue
    if key == -1:
        diameter25[-1] = float(diameter25[-1]/diameter25[0])
        continue
    for i in range(4):
        diameter25[key][i] = int(diameter25[key][i] / diameter25[0])

for key in diameter30:
    if key == 0:
        continue
    if key == -1:
        diameter30[-1] = float(diameter30[-1]/diameter30[0])
        continue
    for i in range(4):
        diameter30[key][i] = int(diameter30[key][i] / diameter30[0])

for key in diameter35:
    if key == 0:
        continue
    if key == -1:
        diameter35[-1] = float(diameter35[-1]/diameter35[0])
        continue
    for i in range(4):
        diameter35[key][i] = int(diameter35[key][i] / diameter35[0])

for key in diameter40:
    if key == 0:
        continue
    if key == -1:
        diameter40[-1] = float(diameter40[-1]/diameter40[0])
        continue
    for i in range(4):
        diameter40[key][i] = int(diameter40[key][i] / diameter40[0])


f = open("AVERAGE_FORMAT", "a")



for key in sorted(diameter05.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter05[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter05[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter10.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter10[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter10[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter15.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter15[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter15[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter20.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter20[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter20[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter25.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter25[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter25[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter30.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter30[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter30[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter35.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter35[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter35[key][i])
    string += "\n"
    f.write(string)

for key in sorted(diameter40.keys()):
    if key == 0 or key == -1:
        continue
    string = "/"
    string += "diameter" + str(diameter40[-1])
    string += "\t"
    if key == -10:
        string += variable + ":N"
    else:
        string += variable + ":" + str(key)
    for i in range(4):
        string += "\t" + str(diameter40[key][i])
    string += "\n"
    f.write(string)




f.close()


format_f = open("AVERAGE_FORMAT", "r")
data_f = open("AVERAGE_DATA", "a")



line = format_f.readline()

while line:
    line = line.split("\t")
    data_f.write("FP: " + line[2] + "\n")
    data_f.write("FN: " + line[3] + "\n")
    data_f.write("TP: " + line[4] + "\n")
    data_f.write("TN: " + line[5])

    line = format_f.readline()

format_f.close()
data_f.close()

