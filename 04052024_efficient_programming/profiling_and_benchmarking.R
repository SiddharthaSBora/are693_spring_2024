library(profvis)
library(microbenchmark)
library(tictoc)

# Profiling and Benchmarking




# Source: https://adv-r.hadley.nz/perf-measure.html

source("./04052024_efficient_programming/profvis_example.R")
profvis(f())




# Microbenchmarking
square_root_1 <- function(x) x ^ (1 / 2)
square_root_2 <- function(x) exp(log(x) / 2)

tic()
square_root_1(2)
toc()

tic()
square_root_2(2)
toc()


bench::mark(square_root_1(12345678), square_root_2(12345678), check = FALSE)


# Compiled code vs Interpreted code

# Compiled R

library("compiler")

getFunction("mean")


mean_r = function(x) {
  m = 0
  n = length(x)
  for (i in seq_len(n))
    m = m + x[i] / n
  m
}

cmp_mean_r = cmpfun(mean_r)

x = rnorm(1000)
microbenchmark(times = 10, unit = "ms", # milliseconds
               mean_r(x), cmp_mean_r(x), mean(x))

# do it for sample sizes 1 to 1000
n = 1:1000
times = numeric(length(n))
for (i in n) {
  x = rnorm(i)
  times[i] = microbenchmark(times = 10, unit = "ms", mean_r(x), cmp_mean_r(x), mean(x))$time[3]
}

# plot a time series graph
plot(n, times, type = "l", xlab = "n", ylab = "time (ms)")
