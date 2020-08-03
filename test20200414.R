library(stringr)
library(dplyr)
input_path <- "/Volumes/Datacenter/IT/SystemAssistant/月例・随時作業関連/入退室ログ/ログデータ/202007/"
filelist <- list.files(input_path)[1:5]
a <- lapply(str_c(input_path, filelist), function(x){read.csv(file=x, header=T, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings="")})
b <- rbind(a[[1]], a[[2]], a[[3]], a[[4]], a[[5]]) %>% filter(!is.na(名前)) %>% select(c("日時", "状況", "名前"))
# カード作成, 削除情報は不要
input_df <- b %>% filter(状況 !="ﾃﾞｰﾀ設定成功(利用者情報)") %>% filter(状況 !="通行ﾚﾍﾞﾙｴﾗｰ")
# 日時を分ける
temp_colname <- colnames(input_df)
input_df <- str_split(input_df$日時, " ", simplify=T) %>% data.frame(stringsAsFactors=F) %>% cbind(input_df)
colnames(input_df) <- c("ymd", "hm", temp_colname)
# 名前、日時でソート
sort_df <- input_df %>% arrange(名前, 日時) %>% write.csv("/Users/admin/Downloads/test.csv", fileEncoding="cp932")
