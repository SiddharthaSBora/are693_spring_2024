# python code to find the nth fibonacci number
import time

def fibonacci(n):
    if n <= 1:
        return n
    else:
        return(fibonacci(n-1) + fibonacci(n-2))

num = 40

# let's find the 50th fibonacci number
start_time = time.time()

fibonacci(num)

print("Time Taken: %s seconds" % (time.time() - start_time))