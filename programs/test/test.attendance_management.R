#' for test
#' Outputs an Excel file for confirmation.
#' @file test.attendance_management.R
#' @author Mariko Ohtsuka
#' @date 2024.2.1
rm(list=ls())
# ------ libraries ------
library(lubridate)
library(tidyverse)
library(here)
library(openxlsx)
# ------ constants ------
kTestConstants <- NULL
# ------ functions ------
GetOneMonthAgoFormattedDate <- function() {
  today <- Sys.Date()
  one_month_ago <- today %m-% months(1)
  formatted_date <- format(one_month_ago, "%Y%m")
  return(formatted_date)
}
# ------ main ------
input_path <- GetOneMonthAgoFormattedDate() %>% str_c("/Volumes/Archives/Log/DC入退室/rawdata/", .)
df_input <- list.files(input_path, full.names=T) %>% map_df( ~ read.csv(., skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings="NA"))
# 日時列をPOSIXct型に変換
df_input$日時 <- as.POSIXct(df_input$日時, format = "%Y/%m/%d %H:%M:%S")

# '名前'毎に集計し、各名前のサブグループとして'日時'の最小と最大を求める
result <- df_input %>% filter(名前 != "") %>%
  group_by(名前, format(日時, "%Y-%m-%d")) %>%
  summarise(
    最早 = format(min(日時), "%H:%M:%S"),
    最晩 =format(max(日時), "%H:%M:%S")
  ) %>% arrange(名前, `format(日時, "%Y-%m-%d")`, 最早, 最晩)
write.xlsx(result, here("output", GetOneMonthAgoFormattedDate() %>% str_c(".xlsx")), overwrite=T)
