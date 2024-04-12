# Julia code to find the nth Fibonacci number
using BenchmarkTools
using Distributions

function fibonacci(n)
    if n <=1
        return n
    else
        return fibonacci(n-1) + fibonacci(n-2)
    end
end

num = 40

@time println("Fibonacci value: ", fibonacci(num))