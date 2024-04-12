# recursive function to generate Nth number of fibonacci sequence
fibonacci <- function(n) {
    if (n <= 1) {
        return(n)
    } else {
        return(fibonacci (n-1) + fibonacci (n-2))
    }
}

# which number you want to generate
num = 40

start_time <- Sys.time()

fibonacci(num)

end_time <- Sys.time()
print(paste0("Time Taken = ", end_time - start_time, " seconds"))