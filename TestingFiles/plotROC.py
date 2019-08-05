import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def plotROC( fpr, tpr, title, num_points, color_map ):
    markers = ["o", "v", "^", "s", "D", "P", "X", "+"]
    plt.xlabel('Precision')
    plt.ylabel('Recall')
    if title == "":
        plt.title('Reviever Operating Characteristic (ROC) Curve')
    else:
        plt.title(title)


    if color_map != []:
        vmin = min(color_map);
        vmax = max(color_map);
        if num_points > 0:
            i = 0
            while i < len(fpr):
                for j in range(num_points):
                    plt.scatter([fpr[i]], [tpr[i]], c = [color_map[i]], vmin = vmin, vmax = vmax, cmap = 'viridis', marker=markers[j])
                    i += 1
                    if i == len(fpr):
                        break
        else:
            plt.scatter(fpr, tpr, c=color_map, cmap='viridis')
    else:
        plt.scatter(fpr, tpr, color='blue');
    plt.plot([0,1], [0,1], color='black', linestyle='--')
    plt.xticks(np.arange(0, 1.2, 0.2))
    plt.yticks(np.arange(0, 1.2, 0.2))
    plt.colorbar()
    plt.show()


USAGE = "python plotROC.py [x axis points] [y axis points] (title) (color map) (point shape loop)"


if len(sys.argv) < 3 or len(sys.argv) > 6:
    print("", flush=True)
    print("\tError: Incorrect number of parameters", flush=True)
    print("");
    print("\tUSAGE: " + USAGE, flush=True)
    exit()

FPR_arr = sys.argv[1].split("#")
TPR_arr = sys.argv[2].split("#")
title = ""
if (len(sys.argv) > 3):
    title = sys.argv[3];
color_map = []
if (len(sys.argv) > 4):
    color_map = sys.argv[4].split("#");
num_points = 0
if (len(sys.argv) > 5):
    num_points = int(sys.argv[5]);
    if num_points > 8:
        print("Error: The maximum number of different markers is 8")
        exit();

if FPR_arr[0] == "" or FPR_arr[0] == " ":
    FPR_arr.pop(0)
if TPR_arr[0] == "" or TPR_arr[0] == " ":
    TPR_arr.pop(0)
if FPR_arr[-1] == "" or FPR_arr[-1] == " ":
    FPR_arr.pop()
if TPR_arr[-1] == "" or TPR_arr[-1] == " ":
    TPR_arr.pop()
if color_map != [] and ( color_map[0] == "" or color_map[0] == " " ):
    color_map.pop(0)
if color_map != [] and ( color_map[-1] == "" or color_map[-1] == " "):
    color_map.pop()


if len(FPR_arr) != len(TPR_arr):
    print("Error: The array lengths do not match", flush=True);
    print("The length of one array is " + str(len(FPR_arr)) + ", but the length of the other is " + str(len(TPR_arr)), flush=True);
    exit();
if color_map != [] and len(TPR_arr) != len(color_map):
    print("Error: The array lengths do not match", flush=True);
    print("The length of the data point arrays are " + str(len(FPR_arr)) + ", but the length of the color map array is " + str(len(color_map)), flush=True);
    exit();


for i in range(len(FPR_arr)):
    FPR_arr[i] = round(float(FPR_arr[i]), 6);
    TPR_arr[i] = round(float(TPR_arr[i]), 6);


for i in range(len(color_map)):
    if len(color_map[i]) > 6:
        color_map[i] = color_map[i][0:6]
    color_map[i] = float(color_map[i]);

plotROC( FPR_arr, TPR_arr, title, num_points, color_map )
