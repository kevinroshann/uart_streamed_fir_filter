h = [0, 5, 4, -5, -10, 0, 24, 45, 45, 24, 0, -10, -5, 4, 5, 0]
x = [1, 2, 3, 4, 5]


outlen=len(x)
a=[]
for i in range(1,outlen+1): #5
    print("````i",i)
    acc=0
    for j in range(1,i+1): #each in the subloop
        acc=acc+h[i-j]*x[j-1]
        print(h[i-j]," x ",x[j-1])
    a.append(acc)

print("acc = ",a)