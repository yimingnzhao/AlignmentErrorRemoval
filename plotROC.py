import sys
import numpy as mp
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def plotROC( fpr, tpr ):
    plt.scatter(fpr, tpr, color='blue', label='ROC')
    plt.plot([0,1], [0,1], color='black', linestyle='--')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Reviever Operating Characteristic (ROC) Curve')
    plt.legend()
    axes = plt.gca()
    axes.set_xlim([0,1])
    axes.set_ylim([0,1])
    plt.show()

print(len(sys.argv))
print(sys.argv[1])
print(sys.argv[2])

FPR_arr = sys.argv[1].split(" ")
FNR_arr = sys.argv[2].split(" ")

if FPR_arr[0] == "":
    FPR_arr.pop(0)
if FNR_arr[0] == "":
    FNR_arr.pop(0)

TPR_arr = []
for i in FNR_arr:
    TPR_arr.append( 1 - float(i))

plotROC( FPR_arr, TPR_arr )
