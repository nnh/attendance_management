#target_yyyymm <- "201906"
library(here)
library(stringr)
library(dplyr)
library(hms)
ReadCsvFunc <- function(input_csv){
  return(read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA"))
}
GroupbyName <- function(input_df){
  output_df <- data.frame(名前=input_df["name"],
                          年月日=input_df["ymd"],
                          入室=input_df["clockin"],
                          退室=input_df["clockout"], stringsAsFactors=F)
  output_df$差分 <- difftime(strptime(input_df["clockout"], "%H:%M:%S"), strptime(input_df["clockin"], "%H:%M:%S"),
                                  units="secs") %>% as.numeric %>% as_hms
  return(output_df)
}
here() %>% setwd()
setwd("..")
input_path <- str_c(getwd(), "/ログデータ")
output_path <- input_path
if (exists("target_yyyymm")){
  yyyymm <- target_yyyymm
} else{
  last_month <- as.Date(format(Sys.Date(), "%Y-%m-01")) - 1
  yyyymm <- str_c(format(last_month, "%Y"), format(last_month, "%m"))
}
input_yyyymm <- str_c(input_path, "/", yyyymm)
output_path <- input_yyyymm
file_list <- list.files(input_yyyymm, full.names=T)
df_attendance <- NULL
for (i in 1:length(file_list)){
  df_attendance <- ReadCsvFunc(file_list[i]) %>% rename(name=名前) %>% bind_rows(df_attendance, .)
}
df_attendance <- df_attendance %>% filter(name != "")
df_attendance$ymd <- as.Date(format(as.Date(df_attendance$日時), "%Y-%m-%d"))
df_attendance$time <- format(as.POSIXct(df_attendance$日時), "%H:%M:%S")
df_output <- NULL
name_list <- df_attendance %>% filter(name != "") %>% distinct(name, .keep_all=F) %>% arrange(name)
# group by name
for (i in 1:nrow(name_list)){
  temp <- df_attendance %>% filter(name == name_list[i, 1]) %>% arrange(ymd)
  temp_max <- temp %>% group_by(ymd) %>% filter(time==max(time)) %>% select(name, ymd, clockout=time)
  temp_min <- temp %>% group_by(ymd) %>% filter(time==min(time)) %>% select(name, ymd, clockin=time)
  temp_min_max <- full_join(temp_min, temp_max, by=c("name", "ymd"))
  # group by date
  df_output <- apply(temp_min_max, 1, GroupbyName) %>% c(df_output, .)
}
write.csv(do.call(rbind, df_output), str_c(output_path, "/", yyyymm, ".csv"), row.names=F, fileEncoding="cp932")
