# attendance_management
# Mariko Ohtsuka
# 2019/10/17
# ------ set date if necessary ------
#target_yyyymm <- "201906"
# ------ libraries ------
library(here)
library(stringr)
library(dplyr)
library(hms)
library(xts)
# ------ functions ------
#' ReadCsvFunc
#' @param input_csv
#' @return
#' @example
ReadCsvFunc <- function(input_csv){
  temp <- read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA")
  if (colnames(temp)[1] == "日時") {
    return(temp)
  } else {
    return(NULL)
  }
}
#' GroupbyName
#' @param input_df A dataframe.
#' @return A data frame with a column for the difference between the start time and end time
#' @example
GroupbyName <- function(input_df){
  output_df <- data.frame(名前=input_df["name"],
                          年月日=input_df["ymd"],
                          入室=input_df["clockin"],
                          退室=input_df["clockout"],
                          stringsAsFactors=F)
  output_df$差分 <- difftime(strptime(input_df["clockout"], "%H:%M:%S"), strptime(input_df["clockin"], "%H:%M:%S"),
                                  units="secs") %>% as.numeric %>% as_hms
  return(output_df)
}
#' GetMonthLastDate
#' @param yyyymm A character
#' @return Last day of month of param
#' @example
GetMonthLastDate <- function(yyyymm){
  yyyy <- str_sub(yyyymm, 1, 4)
  mm <- str_sub(yyyymm, 5, 7)
  if (mm == 12){
    yyyy <- as.character(as.integer(yyyy) + 1)
    mm <- "01"
  } else {
    mm <- as.character(as.integer(mm) + 1)
  }
  next_month <- as.Date(str_c(yyyy, mm, "01", sep="-"))
  return(format(next_month - 1, "%d"))
}
# ------ main ------
here() %>% setwd()
setwd("..")
input_path <- str_c(getwd(), "/ログデータ")
output_path <- input_path
if (exists("target_yyyymm")){
  yyyymm <- target_yyyymm
} else{
  # target the previous month of the execution date
  yyyymm <- Sys.Date() %>% format("%Y-%m-01") %>% as.Date() %>% {. - 1} %>% format("%Y%m")
}
input_yyyymm <- str_c(input_path, "/", yyyymm)
output_path <- input_yyyymm
file_list <- list.files(input_yyyymm, full.names=T)
df_attendance <- NULL
# create a date list
local({
  days <- GetMonthLastDate(yyyymm) %>% seq(1, ., 1) %>% formatC(width=2, flag="0")
  ymd <- as.Date(str_c(str_sub(yyyymm, 1, 4), str_sub(yyyymm, 5, 7), days, sep="-"))
  df_calender <<- data.frame(ymd, stringsAsFactors=F)
})
local({
  for (i in 1:length(file_list)){
    temp <- ReadCsvFunc(file_list[i])
    if (!is.null(temp)){
      df_attendance <<- temp %>% rename(name=名前) %>% bind_rows(df_attendance, .)
    }
  }
})
df_attendance <- df_attendance %>% filter(name != "")
df_attendance$ymd <- as.Date(format(as.Date(df_attendance$日時), "%Y-%m-%d"))
df_attendance$time <- format(as.POSIXct(df_attendance$日時), "%H:%M:%S")
# 5分単位にまるめ
df_attendance$roundup_time <- format(align.time(as.POSIXct(df_attendance$日時), 5*60), "%H:%M:%S")
df_attendance$rounddown_time <- format(align.time(as.POSIXct(df_attendance$日時) - 5*60, 5*60), "%H:%M:%S")
df_output <- NULL
df_output_by_name_all <- NULL
name_list <- df_attendance %>% distinct(name, .keep_all=F) %>% arrange(name)
# group by name
local({
  for (i in 1:nrow(name_list)){
    temp <- df_attendance %>% filter(name == name_list[i, 1]) %>% arrange(ymd)
    temp_max <- temp %>% group_by(ymd) %>% filter(time==max(time)) %>% select(name, ymd, clockout=time, rounddown_time)
    temp_min <- temp %>% group_by(ymd) %>% filter(time==min(time)) %>% select(name, ymd, clockin=time, roundup_time)
    temp_min_max <- full_join(temp_min, temp_max, by=c("name", "ymd"))
    # group by date
    df_output <<- apply(temp_min_max, 1, GroupbyName) %>% c(df_output, .)
    df_output_by_name <- apply(temp_min_max, 1, GroupbyName)
    write.csv(do.call(rbind, df_output_by_name), str_c(output_path, "/", name_list[i, 1], ".csv"), row.names=F, fileEncoding="cp932")
    # output other than work days
    temp_output_by_name <- do.call(rbind, df_output_by_name)
    temp_output_by_name$ymd <- as.Date(temp_output_by_name$年月日)
    df_output_by_name_alldays <- left_join(df_calender, temp_output_by_name, by="ymd")
  }
})
write.csv(do.call(rbind, df_output), str_c(output_path, "/", yyyymm, ".csv"), row.names=F, fileEncoding="cp932")
