// C code to find the nth number of the Fibonnaci sequence
#include <stdio.h>
#include <time.h>

int fibo(int n) {
    if (n <= 1)
        return n;
    else
        return fibo(n - 1) + fibo(n - 2);
}

int main() {
    int num = 40;
    clock_t start_time, end_time;
    double cpu_time_used;

    start_time = clock();

    printf("Fibonacci Number %d\n", fibo(num));

    end_time = clock();
    cpu_time_used = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
    printf("--- %f seconds ---\n", cpu_time_used);

    return 0;
}
