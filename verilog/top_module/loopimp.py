h = [0, 5, 4, -5, -10, 0, 24, 45, 45, 24, 0, -10, -5, 4, 5, 0]
x = [60,70,80,90,100]
import numpy as np



outlen=len(x)
a=[]
for i in range(1,outlen+1): #5
    # print("````i",i)
    acc=0
    for j in range(1,i+1): #each in the subloop
        acc=acc+h[i-j]*x[j-1]
        # print(h[i-j]," x ",x[j-1])
    a.append(acc)


def trunc(a):
    trunc_op = []
    for sum_val in a:
        rounded_sum = sum_val + 64
        scaled_sum = rounded_sum >> 7
        if scaled_sum > 127:
            final_trunc = 127
        elif scaled_sum < -128:
            final_trunc = -128
        else:
            final_trunc = scaled_sum
        trunc_op.append(int(final_trunc))
    return trunc_op

b=trunc(a)
print("filter values before truncation",a)
print("values after truncation", b)


numpyval=np.convolve(h, x)
print("numpy model convolution values",numpyval[:len(x)])

c=trunc(numpyval)

print("trunc op of convolve implementation", c[:len(x)])
