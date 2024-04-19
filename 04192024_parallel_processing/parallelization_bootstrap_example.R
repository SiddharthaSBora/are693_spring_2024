# This example is adapted from Chapter 22 the book "R Programming for Data Science" by Roger D. Peng
# https://bookdown.org/rdpeng/rprogdatascience/parallel-computation.html

library("parallel")
library("tictoc")


# Let's find out how many logical cores are present in your computer
detectCores()

# The rule of thumb is to use one less than the number of logical cores, else your computer will freeze.


# Let us consider running a simple for loop that takes 1 second to run using the lapply function. 
# How much time it takes?

tic()
r <- lapply(1:10, function(i) {
  Sys.sleep(1)  ## Do nothing for 1 second
})
toc()

## We may achieve better performance using the mclapply function, which is a parallel version of lapply.
tic()
r <- mclapply(1:10, function(i) {
  Sys.sleep(1)  ## Do nothing for 1 second
  }, mc.cores = 10) 
toc()



## Example 2: Bootstrapping

# Bootstrapping is the workshorse of time-series work

# let's create a left-skewed distribution of income
set.seed(123)
income <- 100000*rgamma(1000, shape = 1, scale = 1)
hist(income)

# this looks realistic for an income distribution

# we want to estimate the median of this distribution

tic()
set.seed(123)
median_boot <- replicate(10000, {
  bootstrap_sample <- sample(income, replace = TRUE)
  median(bootstrap_sample)
  })
quantile(median_boot, c(0.025, 0.975))
toc()

# let's plot the histogram of the bootstrap distribution
hist(median_boot)

# median of the bootstrap distribution
mean(median_boot)
# 95% confidence interval
quantile(median_boot, c(0.025, 0.975))


# Now let's parallelize the bootstrapping process
tic()
RNGkind("L'Ecuyer-CMRG")
set.seed(123)
median_boot <- mclapply(1:1000, function(i) {
  xnew <- sample(income, replace = TRUE)
  median(xnew)
  }, mc.cores = 5)
median_boot <- unlist(median_boot)  ## Collapse list into vector
quantile(median_boot, c(0.025, 0.975))
toc()









