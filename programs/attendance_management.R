# attendance_management
# Mariko Ohtsuka
# 2021/07/01
# ------ set date if necessary ------
#target_yyyymm <- "201906"
# ------ libraries ------
library(tidyverse)
library(hms)
library(xts)
library(here)
# ------ functions ------
#' ReadCsvFunc
#' @param input_csv
#' @return If the first column name is "日時", return CSV data, otherwise return NULL
#' @example temp <- ReadCsvFunc(file_list[i])
ReadCsvFunc <- function(input_csv){
  temp <- read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA")
  if (colnames(temp)[1] == "日時") {
    return(temp)
  } else {
    return(NULL)
  }
}
#' GetMonthLastDate
#' @param yyyymm A character
#' @return Last day of month of param
#' @example GetMonthLastDate(yyyymm)
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
os <- .Platform$OS.type  # mac or windows
parent_path <- ""
if (os == "unix"){
  volume_str <- "/Volumes"
} else{
  volume_str <- "//aronas"
}
input_parent_path <- "/Archives/Log/DC入退室/rawdata/"
output_parent_path <- here("output")
input_path <- str_c(volume_str, input_parent_path)
if (exists("target_yyyymm")){
  yyyymm <- target_yyyymm
} else{
  # target the previous month of the execution date
  yyyymm <- Sys.Date() %>% format("%Y-%m-01") %>% as.Date() %>% {. - 1} %>% format("%Y%m")
}
input_yyyymm <- str_c(input_path, "/", yyyymm)
output_path <- str_c(output_parent_path, "/", yyyymm)
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
file_list <- list.files(input_yyyymm, full.names=T, pattern="^.*.csv")
df_attendance <- NULL
# create a date list
local({
  days <- GetMonthLastDate(yyyymm) %>% seq(1, ., 1) %>% formatC(width=2, flag="0")
  ymd <- str_c(str_sub(yyyymm, 1, 4), str_sub(yyyymm, 5, 7), days, sep="-") %>% as.Date()
  df_calender <<- data.frame(ymd, stringsAsFactors=F)
})
df_attendance <- map(file_list, ReadCsvFunc) %>%
                  bind_rows(df_attendance, .) %>%
                    rename(name=名前) %>%
                      filter(name != "") %>%
                        filter(状況 != "ﾃﾞｰﾀ設定成功(利用者情報)" & 状況 != "通行ﾚﾍﾞﾙｴﾗｰ")
df_attendance$ymd <- as.Date(df_attendance$日時)
df_attendance$time <- format(as.POSIXct(df_attendance$日時), "%H:%M:00")
name_list <- df_attendance %>% distinct(name, .keep_all=F) %>% arrange(name)
# group by name
df_output_by_name <- map(name_list[[1]], function(target_name){
  temp <- df_attendance %>% filter(name == target_name) %>% group_by(ymd)
  temp_max <- temp %>% filter(time==max(time)) %>% select(name, ymd, clockout=time) %>% distinct(clockout, .keep_all=T)
  temp_min <- temp %>% filter(time==min(time)) %>% select(name, ymd, clockin=time) %>% distinct(clockin, .keep_all=T)
  output_df <- full_join(temp_min, temp_max, by=c("name", "ymd")) %>% right_join(df_calender, by="ymd") %>%
                    arrange(ymd) %>% ungroup() %>% select(clockin, clockout)
  # Remove numbers and spaces from file names
  output_file_name <- str_replace_all(target_name, pattern="[0-9|\\s|　]", "")
  if (output_file_name == ""){
    output_file_name <- target_name
  }
  write.table(output_df, str_c(output_path, "/", output_file_name, ".txt"), sep="\t", na="",
              row.names=F, col.names=F, fileEncoding="cp932")
  return(output_df)
})
