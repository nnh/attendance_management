# create_test_data_202605.R
# テスト用ダミー入力CSVを生成します。
# 前提: output/202605/ に実行済みの出力が存在すること
# 初回のみ実行し、生成されたファイルをgitにコミットしてください。

library(here)
library(tidyverse)
library(lubridate)

# ------ 設定 ------
test_yyyymm  <- "202605"
year_month   <- "2026-05"
original_dir <- here("output", test_yyyymm)
input_dir    <- here("input",  str_c("test_", test_yyyymm))

# 氏名マッピングを output/202605/ のファイル一覧から動的に生成する
# （実名をスクリプトにハードコードしない）
txt_files_for_map <- sort(list.files(here("output", test_yyyymm), pattern = "\\.txt$"))
original_names    <- tools::file_path_sans_ext(txt_files_for_map)
letters_seq       <- c(LETTERS, paste0("A", LETTERS))
dummy_names       <- paste0("User", letters_seq[seq_along(original_names)])
name_map          <- setNames(dummy_names, original_names)

# 乱数シード（再実行時に同じ結果を得るために固定）
set.seed(42)

# ------ ヘルパー関数 ------

#' "HH:MM:SS" 形式の時刻にランダムなオフセット（±90分）を加算する
#'
#' @param time_str "HH:MM:SS" 形式の文字列
#'
#' @return "HH:MM:SS" 形式の文字列
randomize_time <- function(time_str) {
  offset <- sample(-90:90, 1)
  t <- as.POSIXct(str_c("2000-01-01 ", time_str), format = "%Y-%m-%d %H:%M:%S")
  format(t + lubridate::minutes(offset), "%H:%M:%S")
}

# ------ メイン ------
if (!dir.exists(original_dir)) {
  stop("output/", test_yyyymm, "/ が存在しません。先に通常実行してください。")
}
dir.create(input_dir, showWarnings = FALSE, recursive = TRUE)

txt_files  <- list.files(original_dir, pattern = "\\.txt$", full.names = FALSE)
input_rows <- list()

for (file in txt_files) {
  original_name <- tools::file_path_sans_ext(file)
  dummy_name    <- if (original_name %in% names(name_map)) name_map[[original_name]] else original_name

  lines <- readLines(file.path(original_dir, file), encoding = "cp932", warn = FALSE)

  # データあり行のインデックスを取得し、同数のランダムな日付を割り当てる
  active_days <- which(sapply(lines, function(l) {
    parts <- strsplit(l, "\t")[[1]]
    any(gsub('"', '', parts) != "")
  }))
  random_days <- sort(sample(1:length(lines), length(active_days)))
  day_map     <- setNames(random_days, active_days)

  for (i in active_days) {
    parts    <- strsplit(lines[i], "\t")[[1]]
    clockin  <- gsub('"', '', if (length(parts) >= 1) parts[1] else "")
    clockout <- gsub('"', '', if (length(parts) >= 2) parts[2] else "")

    if (clockin == "" && clockout == "") next

    new_ci <- if (clockin  != "") randomize_time(clockin)  else ""
    new_co <- if (clockout != "") randomize_time(clockout) else ""
    # 入退室が逆転した場合は入れ替え
    if (new_ci != "" && new_co != "" && new_ci > new_co) {
      tmp <- new_ci; new_ci <- new_co; new_co <- tmp
    }

    day      <- formatC(day_map[[as.character(i)]], width = 2, flag = "0")
    date_str <- str_c(year_month, "-", day)

    if (new_ci != "") {
      input_rows[[length(input_rows) + 1]] <- data.frame(
        日時 = str_c(date_str, " ", new_ci), 名前 = dummy_name, 状況 = "入室",
        stringsAsFactors = FALSE
      )
    }
    # 入退室が同一時刻の場合は1行のみ
    if (new_co != "" && new_co != new_ci) {
      input_rows[[length(input_rows) + 1]] <- data.frame(
        日時 = str_c(date_str, " ", new_co), 名前 = dummy_name, 状況 = "退室",
        stringsAsFactors = FALSE
      )
    }
  }
}

# 入力CSVを書き出し（先頭3行はスキップされるダミーヘッダー）
df_input <- bind_rows(input_rows) |> arrange(日時, 名前)
csv_path <- file.path(input_dir, "attendance_log.csv")

con <- file(csv_path, encoding = "cp932", open = "w")
writeLines(c("出入力ログ", "2026年05月", "テストデータ"), con = con)
close(con)
write.table(df_input, csv_path, sep = ",", row.names = FALSE, col.names = TRUE,
            fileEncoding = "cp932", append = TRUE, quote = TRUE)

cat("ダミー入力CSV生成完了\n")
cat("  入力CSV :", csv_path, "\n")
cat("  対象人数 :", length(txt_files), "名\n")
cat("  入力行数 :", nrow(df_input), "行\n")
