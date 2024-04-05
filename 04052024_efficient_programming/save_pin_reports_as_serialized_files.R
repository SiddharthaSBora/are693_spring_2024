# data cleaning
library(tidyverse)
library(dplyr)
library(janitor)
library(tictoc)
library(feather)
library(arrow)

# The ideas come from 
# https://www.r-bloggers.com/2022/05/comparing-performances-of-csv-to-rds-parquet-and-feather-file-formats-in-r/

# Somewhat dated, but still useful ideas are in 
# https://blog.djnavarro.net/posts/2021-11-15_serialisation-with-rds/

#filter out pin reports
location <- paste0(raw_data_location, "WVU_Counties_USDA")

pin_reports <- list.files(location, 
                          full.names = T, 
                          recursive = T,
                          pattern = "pin_report.tsv.gz")

county_pin_reports <- pin_reports[str_detect(pin_reports, "Grant")]


# Read all files in grant_pin_reports using purrr::map (all 48 months), it takes 77 second in my computer
# I found that read_tsv is faster than read_delim
tic()
pin_reports <- county_pin_reports%>%
  purrr::map(read_tsv)
toc()
  
# This is a big list of dataframes, which we want to convert to single dataframe. 
# Observe that I am using the same variable to preserve memory, takes 61 seconds in my computer
tic()
pin_reports <- bind_rows(pin_reports, .id = "source_id")%>%
  clean_names()
toc()


#Now let's save the data as rds, serialized data format. Took 386 seconds, and the size of file 
# was 1.78 GB on disk
tic()
saveRDS(pin_reports, file = "./0_data/grant_pin_reports.rds")
toc()


# Now we can load the data using readRDS. It took 107 seconds (less than 77+61)
tic()
pin_reports<-readRDS("./0_data/grant_pin_reports.rds")
toc()


# writing as feather file took 32 seconds, and the size of file was 12.58 GB on disk.
# Performance wise it was encouraging, but the file size was too big
tic()
write_feather(pin_reports, "./0_data/grant_pin_reports.feather")
toc()

# reading the feather file gave an error I do not understand yet. So, let's drop feather
tic()
pin_reports <- read_feather("./0_data/grant_pin_reports.feather")
toc()

# try parquet format, takes 67 seconds to write, and the size of file was 2 GB on disk
# so represents a good tradeoff between speed and size
tic()
write_parquet(pin_reports, "./0_data/grant_pin_reports.parquet")
toc()

# let's see how long it takes to read the parquet file. It took 9 seconds to read!!!!
tic()
pin_reports <- read_parquet("./0_data/grant_pin_reports.parquet")
toc()


# So let's collect the data for each year separately for county and save them as
# parquet files!

#function to collect and serialize data for each county

serialize = function(county_name){
  location <- paste0(raw_data_location, "WVU_Counties_USDA") 
  
  pin_reports <- list.files(location, 
                            full.names = T, 
                            recursive = T,
                            pattern = "pin_report.tsv.gz")
  
  county_pin_reports <- pin_reports[str_detect(pin_reports, county_name)]
  
  pin_reports <- county_pin_reports%>%
    purrr::map(read_tsv)
  
  pin_reports <- bind_rows(pin_reports, .id = "source_id")%>%
    clean_names()
  
  return(pin_reports)
}

#run function separately for each "county_name" and then save as parquet

pin_reports <- serialize("Randolph")

write_parquet(pin_reports, "./0_data/randolph_pin_reports.parquet")

