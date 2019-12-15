import numpy as np
import random
import matplotlib as m
import math
from matplotlib.pyplot import plot
from random import randrange

p = []
N = 20
nmax = 100
nD = 50
alpha = [0.75, 1.0, 1.25, 1.50, 1.75, 2.0, 2.25, 2.50, 2.75, 3.0]
S = []
length = len(alpha)

for i in range(length):
    a = alpha[i]
    for j in range(nD):
        P = math.ceil(a*N)
        data = np.random.randn(P,N)
        S.append(-1)
        for i in range(1,P):
            if i%2 == 0:
                S.append(-1)
            else:
                S.append(1)
        S = np.array(S)
        w = np.zeros([1,N])
        for n in range(nmax):
            success = 1
            for t in range(P):
                E = np.dot(w,data[t,:])*S[t]
                if (E <= 0):
                    w = w+((1/N)*data[t,:]*S[t])
                    success = 0
            if(success == 1):
                p[i]+=1
                break
    p[i] = p[i]/nD
plot(alpha,p)