import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def plotROC( fpr, tpr, labels ):
    plt.xlabel('Precision')
    plt.ylabel('Recall')
    plt.title('Reviever Operating Characteristic (ROC) Curve')
    plt.legend()
    plt.scatter(fpr, tpr, color='blue')
    for i in range(len(labels)):
        plt.annotate( labels[i], (fpr[i], tpr[i]));
    plt.plot([0,1], [0,1], color='black', linestyle='--')
    plt.xticks(np.arange(0, 1.2, 0.2))
    plt.yticks(np.arange(0, 1.2, 0.2))
    plt.show()



FPR_arr = sys.argv[1].split(" ")
TPR_arr = sys.argv[2].split(" ")
labels_arr = []
if (len(sys.argv) == 4):
    labels_arr = sys.argv[3].split(" ");

if FPR_arr[0] == "":
    FPR_arr.pop(0)
if TPR_arr[0] == "":
    TPR_arr.pop(0)

if len(FPR_arr) != len(TPR_arr):
    print("Error: The array lengths do not match");
    exit();


for i in range(len(FPR_arr)):
    FPR_arr[i] = round(float(FPR_arr[i]), 6);
    TPR_arr[i] = round(float(TPR_arr[i]), 6);



plotROC( FPR_arr, TPR_arr, labels_arr )
