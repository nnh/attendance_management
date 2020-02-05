# テスト用
library(dplyr)
ReadCsvFunc <- function(input_csv){
  temp <- read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA")
  if (colnames(temp)[1] == "日時") {
    return(temp)
  } else {
    return(NULL)
  }
}
csv1 <- ReadCsvFunc("/Users/admin/Documents/GitHub/ログデータ/202001/20200127-20200131HFK.csv")
csv2 <- ReadCsvFunc("/Users/admin/Documents/GitHub/ログデータ/202001/20200121-20200126HFK.csv")
csv3 <- ReadCsvFunc("/Users/admin/Documents/GitHub/ログデータ/202001/20200116-20200120HFK.csv")
csv4 <- ReadCsvFunc("/Users/admin/Documents/GitHub/ログデータ/202001/20200111-20200115HFK.csv")
csv5 <- ReadCsvFunc("/Users/admin/Documents/GitHub/ログデータ/202001/20200106-20200110HFK.csv")
csv <- rbind(csv1, csv2, csv3, csv4, csv5) %>% filter(状況 == "入退室操作" |状況 == "有効操作")
csv$day <- as.Date(csv$日時)
csv$time <- strftime(csv$日時, "%H:%M:%S")

in_time <- filter(group_by(csv, 名前, day), time == min(time)) %>% select(c("名前", "day", "time"))
out_time <- filter(group_by(csv, 名前, day), time == max(time)) %>% select(c("名前", "day", "time"))
in_out_time <- in_time %>% inner_join(out_time, by=c("名前", "day")) %>% arrange(名前, day)
namelist <- unique(in_out_time$名前)
days <- seq(1, 31, 1) %>% formatC(width=2, flag="0")
day <- str_c("2020", "01", days, sep="-")
df_calender <- data.frame(as.Date(day), stringsAsFactors=F)
colnames(df_calender) <- "day"
for (i in 1:length(namelist)){
  output_file_name <- str_replace_all(namelist[i], pattern="[0-9|\\s|　]", "")
  temp <- in_out_time %>% filter(名前 == namelist[i]) %>% distinct(day, .keep_all=T)
  output <- left_join(df_calender, temp, by="day") %>% select(c("time.x", "time.y"))
  write.table(output, str_c("/Users/admin/Documents/GitHub/ログデータ/202001/test/", output_file_name, ".txt"), sep="\t", na="",
              row.names=F, col.names=F, fileEncoding="cp932")
}
