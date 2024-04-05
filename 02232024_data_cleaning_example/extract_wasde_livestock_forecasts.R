library("tidyverse")
library("pdftools")


# USDA WASDE reports are released every month.
# https://www.usda.gov/oce/commodity/wasde

# USDA has posted all their archived reports in Cornell Mann Library that goes back to 1973
# https://usda.library.cornell.edu/concern/publications/3t945q76s?locale=en

# The report contains data on various commodities. In this case I am interested
# in livestock prices. These days they release data in Excel, which makes it easier
# to analyse/extract. But in old days, they were just pdfs, and early reports were
# just scans.

# I want to extract livestock prices from these reports, and create CSV file
# suitable for time-series analysis. I have done it for all years, and wrote a paper.

# I will demonstrate how I did it for 1999.But it is generalizable depending on format of the reports.


# I didn't have to do this, but I will slightly automatize the process of downloading 
# the reports for you, as I do not want to commit the PDF reports to the repository.

wasde_1999_urls<-c("https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/4f16c317n/jh343s70d/wasde-01-12-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/3197xm437/w6634402d/wasde-02-10-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/37720d11k/1g05fb816/wasde-03-11-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/4j03cz965/5425kb09t/wasde-04-09-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/cz30pt05d/02870w387/wasde-05-12-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/sb3978546/8c97kq715/wasde-06-11-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/s4655g95p/v692t6634/wasde-07-12-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/0p096728s/7w62f862t/wasde-08-12-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/5x21tf783/47429956k/wasde-09-10-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/xd07gt02n/474299559/wasde-10-08-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/9w032331g/5999n3812/wasde-11-10-1999.pdf",
                   "https://downloads.usda.library.cornell.edu/usda-esmis/files/3t945q76s/zk51vh06v/rv042t36q/wasde-12-10-1999.pdf")


# let's create a directory for keeping files
file_destination <- "./data/wasde_1999/"
dir.create(file_destination, showWarnings = FALSE)

# this little function is a wrapper to download.file, but it also extracts the file name, and stores
# where we want
download_file<-function(file_url, file_destination)
{
  file_name<-str_split_i(file_url, "/", -1)
  download.file(file_url, paste0(file_destination, file_name))
}

# Now apply the function to all urls, not that for loop is avoided using map from purrr. 
wasde_1999_urls%>%
  map(~download_file(., file_destination))


# Now the download is over, let's try to clean the data from the PDFs
file_names<-list.files(file_destination, ".pdf", full.names = T)

file<-file_names[1]

# This function will read a monthly report and spit out what we need from livestock
# price table
extract_monthly_livestock_prices<-function(file)
{
    
    release_date<-mdy(str_extract(file, "\\d{2}-\\d{2}-\\d{4}")) #release date
    
    # Extract the table from PDF
    mydata<-pdf_text(file) # read the whole pdf doc
    page_number<-which(str_detect(mydata, "U.S. Quarterly Animal Product Production 1/")) # find the page number
    mydata<-tibble(mystring=as.vector(str_split(mydata[page_number], "\n", simplify = T)))
    
    start_row<-mydata %>%
      mutate(mystring=trimws(mystring))%>%
      rowid_to_column()%>%
      filter(str_detect(mystring, "U.S. Quarterly Prices for Animal Products"))%>%
      select(rowid)%>%
      as.numeric()
    
    # tidy it
    mydata_tidy <-mydata %>%
      slice(start_row:n())%>%
      slice(8:27)%>%
      separate(mystring, c("vars", "value"), ":", fill="right") %>%
      mutate(vars=str_replace_all(vars, pattern=" ", repl=""),
             value=trimws(value))%>%
      mutate(vars=trimws(vars),
             value=trimws(value))%>%
      mutate(report_year=year(release_date),
             report_month=month(release_date, label = TRUE),
             report_date=release_date)%>%
      separate(value, c("steers", "barrows_and_gilts", "broilers", "turkey", "eggs", "milk"), 
               sep="[[:space:]]{1,}", fill = "right")%>%
      mutate(year=as.numeric(str_extract(vars, "\\d{4}")))%>%
      fill(year)%>%
      filter(vars %in% c("I", "II", "III", "IV", "I*", "II*", "III*", "IV*"))%>%
      mutate(type=case_when(str_detect(vars, "\\*")~"forecast",
                            TRUE~"estimate"),
             vars=as.numeric(as.roman(str_replace(vars, '\\*', ''))))%>%
      select(report_year, report_month, report_date, year, quarter=vars, type, steers, barrows_and_gilts, broilers, turkey, eggs, milk)
    
    return(mydata_tidy)
}

# lets test it for January 1999
extract_monthly_livestock_prices(file_names[1])

# Now let's apply the function to all files
wasde_livestick_prices<-file_names%>%
  map(extract_monthly_livestock_prices)%>%
  reduce(rbind)


# save the file as csv
write_csv(wasde_livestick_prices, "./data/wasde_livestick_prices_1999.csv")

# now you can proceed to do further cleaning and do time series work. The process
# can be extended to other years.
