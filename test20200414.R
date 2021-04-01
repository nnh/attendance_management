library(tidyverse)
input_path <- "/Volumes/Datacenter/IT/SystemAssistant/月例・随時作業関連/入退室ログ/ログデータ/202103/"
filelist <- list.files(input_path)[1:4]
a <- lapply(str_c(input_path, filelist), function(x){read.csv(file=x, header=T, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings="")})
b <- rbind(a[[1]], a[[2]], a[[3]], a[[4]]) %>% filter(!is.na(名前)) %>% select(c("日時", "状況", "名前"))
# カード作成, 削除情報は不要
input_df <- b %>% filter(状況 !="ﾃﾞｰﾀ設定成功(利用者情報)") %>% filter(状況 !="通行ﾚﾍﾞﾙｴﾗｰ")
# 日時を分ける
temp_colname <- colnames(input_df)
input_df <- str_split(input_df$日時, " ", simplify=T) %>% data.frame(stringsAsFactors=F) %>% cbind(input_df)
colnames(input_df) <- c("ymd", "hm", temp_colname)
# 名前、日時でソートしてCSV出力
sort_df <- input_df %>% arrange(名前, 日時)
sort_df %>% write.csv("/Users/mariko/Downloads/test.csv", fileEncoding="cp932")
# 前の行と日付が違ったら出社時間とする
# 次の行と日付が違ったら退社時間とする
wk_df <- sort_df
wk_df$check_f <- 1
wk_df[nrow(wk_df), "check_f"] <- 2
wk_df$trunc_time <- trunc_hms(as_hms(wk_df$hm), 60)
for (i in 2:(nrow(wk_df)-1)){
    if (wk_df[i-1, "ymd"] != wk_df[i, "ymd"]){
      wk_df[i, "check_f"] <- 1
    } else if (wk_df[i+1, "ymd"] != wk_df[i, "ymd"]){
      wk_df[i, "check_f"] <- 2
    } else {
      wk_df[i, "check_f"] <- 0
    }
}
output_df <- wk_df %>% filter(check_f > 0) %>% select(名前, ymd, trunc_time, check_f)
output_df_in <- output_df %>% filter(check_f == 1)
output_df_out <- output_df %>% filter(check_f == 2)
output_df <- left_join(output_df_in, output_df_out, by=c("名前", "ymd")) %>% select(名前, ymd, in_time=trunc_time.x, out_time=trunc_time.y)
output_df %>% write.csv("/Users/mariko/Downloads/sort.csv", fileEncoding="cp932")
