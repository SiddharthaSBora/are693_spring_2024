# optimizing I/O operations using serialization

# data cleaning
library("tidyverse")
library("dplyr")
library("janitor")
library("tictoc")
library("feather")
library("arrow")

# Let's download PPP load data from Small Business Administration website

# https://data.sba.gov/dataset/ppp-foia

file_url <- "https://data.sba.gov/dataset/8aa276e2-6cab-4f86-aca4-a7dde42adf24/resource/738e639c-1fbf-4e16-beb0-a223831011e8/download/public_150k_plus_230930.csv"

#download file if it does not exist
if(!file.exists("./data/public_150k_plus_230930.csv"))
  download.file(file_url, destfile = "./data/public_150k_plus_230930.csv")

# observe time taken in each operation below, also observe the size of the file on disk

# read data using tidyverse functions
tic()
ppp_data <- read_csv("./data/public_150k_plus_230930.csv")
toc()

# write into a csv format
tic()
write_csv(ppp_data, "./data/ppp_data_saved.csv")
toc()


#Now let's save the data as rds, serialized data format. 
tic()
saveRDS(ppp_data, file = "./data/ppp_data_saved.rds")
toc()


# Now we can load the data using readRDS. 
tic()
ppp_data<-readRDS("./data/ppp_data_saved.rds")
toc()


# feather format
tic()
write_feather(ppp_data, "./data/ppp_data_saved.feather")
toc()

# reading the feather file gave an error I do not understand yet. So, let's drop feather
tic()
ppp_data <- read_feather("./data/ppp_data_saved.feather")
toc()

# try parquet format
tic()
write_parquet(ppp_data, "./data/ppp_data_saved.parquet")
toc()

# let's see how long it takes to read the parquet file.
tic()
pin_reports <- read_parquet("./data/ppp_data_saved.parquet")
toc()


