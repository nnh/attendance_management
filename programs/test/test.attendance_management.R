#' @file test.attendance_management.R
#' @author Mariko Ohtsuka
#' @date 2021.12.3
rm(list=ls())
# ------ libraries ------
library(RUnit)
library(here)
source(here('programs', 'common.R'), encoding='utf-8')
# ------ main ------
os <- GetOsType()  # mac or windows
parent_path <- ""
if (os == "unix"){
  volume_str <- "/Volumes"
} else{
  volume_str <- "//aronas"
}
input_parent_path <- "/Archives/Log/DC入退室/rawdata/"
input_path <- str_c(volume_str, input_parent_path)
yyyymm <- GetYyyymm()
input_yyyymm <- str_c(input_path, "/", yyyymm)
output_path <- here('output', str_c("test_", yyyymm))
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
file_list <- list.files(input_yyyymm, full.names=T, pattern="^.*.csv")
csv_list <- file_list %>% map(~{
  temp_csv <- ReadCsvFunc(.) %>% filter(状況 != "ﾃﾞｰﾀ設定成功(利用者情報)" & 状況 != "通行ﾚﾍﾞﾙｴﾗｰ") %>% filter(名前 != "")
  return(temp_csv)
})
df_attendance <- bind_rows(csv_list[[1]], csv_list[[2]], csv_list[[3]])
df_attendance <- df_attendance %>% arrange(日時)
df_attendance <- df_attendance %>% separate(日時, c('date', 'time'), sep=' ')
df_attendance$time <- df_attendance$time %>% str_replace('[0-9][0-9]$', '00')
df_attendance$output_row <- df_attendance$date %>% str_extract('[0-9][0-9]$') %>% as.numeric()
df_in <- df_attendance %>% group_by(名前, date) %>% filter(time == min(time))
df_out <- df_attendance %>% group_by(名前, date) %>% filter(time == max(time))
df_in <- df_in %>% ungroup()
df_out <- df_out %>% ungroup()
user_list <- df_in$名前 %>% unique()
user_list %>% map(~{
  user <- .
  output_file_name <- str_replace_all(user, pattern="[0-9|\\s|　]", "")
  temp_in <- df_in %>% filter(名前 == user)
  temp_out <- df_out %>% filter(名前 == user)
  output_df <- data.frame(1:31, NA, NA) %>% select(c(2, 3))
  for (i in 1:nrow(temp_in)){
    output_row <- temp_in[i, 'output_row', drop=T]
    output_df[output_row, 1] <- temp_in[i, 'time']
  }
  for (i in 1:nrow(temp_out)){
    output_row <- temp_out[i, 'output_row', drop=T]
    output_df[output_row, 2] <- temp_out[i, 'time']
  }
  write.table(output_df, str_c(output_path, "/", output_file_name, ".txt"), sep="\t", na="",
              row.names=F, col.names=F, fileEncoding="cp932")
})
'*** compare dataframe ***' %>% print()
rm(list=ls())
library(RUnit)
library(here)
source(here('programs', 'common.R'), encoding='utf-8')
yyyymm <- GetYyyymm()
target_files <- list.files(here('output', yyyymm))
compare_files <- list.files(here('output', str_c('test_', yyyymm)))
'*** check output filelist  ***' %>% print()
check_f <- RUnit::checkIdentical(target_files, compare_files)
for (i in 1:length(target_files)){
  target_df <- read.table(here('output', yyyymm, target_files[[i]]), sep="\t")
  compare_df <- read.table(here('output', str_c('test_', yyyymm), target_files[[i]]), sep="\t")
  if (nrow(target_df) == 30 & nrow(compare_df) == 31){
    target_df[31, 1] <- ''
    target_df[31, 2] <- ''
  }
  target_files[[i]] %>% print()
  temp <- RUnit::checkIdentical(compare_df, target_df)
  if (!temp){
    check_f <- temp
  }
}
if (check_f){
  print('*** test ok ***')
}
