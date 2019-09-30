library(stringr)
filter_by_name_input_path <- "/Users/admin/Documents/GitHub/ログデータ/output"
filter_by_name_output_path <- str_c(filter_by_name_input_path, "/output_filter_by_name")
input_name <- "" #"抽出対象者の名前"
filter_by_name_file_list <- list.files(path = filter_by_name_input_path, full.names = T)
target <- filter_by_name_file_list[-which(filter_by_name_file_list %in% "/Users/admin/Documents/GitHub/ログデータ/output/output_filter_by_name")]
temp_target_name_list <- str_split(target, "/")
target_name <- NULL
for (i in 1:length(temp_target_name_list)){
  temp_target_name <- temp_target_name_list[[i]]
  target_name[i] <- temp_target_name[length(temp_target_name_list[[i]])]
}
rbind_csv <- NULL
for (i in 1:length(target)){
  temp_csv <- read.csv(target[i], fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA")
  temp_csv <- subset(temp_csv, 名前 == input_name)
  write.csv(temp_csv, str_c(filter_by_name_output_path, "/", target_name[i]), row.names=F, fileEncoding="cp932")

  rbind_csv <- rbind(rbind_csv, temp_csv)
}
write.csv(rbind_csv, str_c(filter_by_name_output_path, "/rbind.csv"), row.names=F, fileEncoding="cp932")
