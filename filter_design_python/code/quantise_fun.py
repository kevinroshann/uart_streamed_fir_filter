import math


def quantise(n):
    b=7
    c=2**b
    e=n*c
    f=round(e)
    if(f>127):
        f=127
    if(f<-128):
        f=-128
    return f




