#install.packages("hms")
library(here)
library(stringr)
library(dplyr)
library(hms)
ReadCsvFunc <- function(input_csv){
  return(read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA"))
}
here() %>% setwd()
setwd("..")
input_path <- str_c(getwd(), "/ログデータ")
last_month <- as.Date(format(Sys.Date(), "%Y-%m-01")) - 1
yyyymm <- str_c(format(last_month, "%Y"), format(last_month, "%m"))
input_yyyymm <- str_c(input_path, "/", yyyymm)
file_list <- list.files(input_yyyymm, full.names=T)
df_attendance <- ReadCsvFunc(file_list[1])
for (i in 2:length(file_list)){
  df_attendance <- bind_rows(df_attendance, ReadCsvFunc(file_list[i]))
}
# output dataframe
df_output <- data.frame(matrix(rep(NA, 5), nrow=1))[numeric(0), ]
temp_output <- df_output
name_list <- df_attendance %>% filter(名前 != "") %>% distinct(名前, .keep_all=F) %>% arrange(名前)
# group by name
for (i in 1:nrow(name_list)){
  temp <- df_attendance %>% filter(名前 == name_list[i, 1]) %>% arrange(日時)
  temp$ymd <- as.Date(format(as.Date(temp$日時), "%Y-%m-%d"))
  temp$time <- format(as.POSIXct(temp$日時), "%H:%M:%S")
  temp_max <- temp %>% group_by(ymd) %>% filter(time==max(time)) %>% select(名前, ymd, clockout=time)
  temp_min <- temp %>% group_by(ymd) %>% filter(time==min(time)) %>% select(名前, ymd, clockin=time)
  temp_min_max <- full_join(temp_min, temp_max, by=c("名前", "ymd"))
  temp_min_max$time_diff <- NA
  # group by date
  for (j in 1:nrow(temp_min_max)){
    temp_c_in <- strptime(temp_min_max[j,"clockin"], "%H:%M:%S")
    temp_c_out <- strptime(temp_min_max[j,"clockout"], "%H:%M:%S")
    temp_diff <- as_hms(as.numeric(difftime(temp_c_out, temp_c_in, units="secs")))
    temp_output[1, 1] <- temp_min_max[j, "名前"]
    temp_output[1, 2] <- format(temp_min_max[j, "ymd"][[1]], "%Y/%m/%d")
    temp_output[1, 3] <- temp_min_max[j,"clockin"]
    temp_output[1, 4] <- temp_min_max[j,"clockout"]
    temp_output[1, 5] <- format(temp_diff, "%H:%M:%S")
    df_output <- rbind(df_output, temp_output)
  }
}
