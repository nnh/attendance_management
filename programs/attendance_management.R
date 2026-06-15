# attendance_management.R
# author: Mariko Ohtsuka
# date: 2026/6/15
# 入退室ログCSVから個人別の出勤・退勤時刻テキストファイルを生成します。

# ------ 対象年月の指定（通常はコメントアウトのまま） ------
# 指定しない場合は実行日の前月が自動で対象になります。
# target_yyyymm <- "202401"

# ------ ライブラリ・共通関数 ------
library(here)
options(conflictRules = list(dplyr = list(exclude = "lag")))
options(xts.warn_dplyr_breaks_lag = FALSE)
source(here("programs", "common.R"), encoding = "utf-8")

# ------ パス設定 ------
# OS によってネットワークドライブのルートと Box のパスが異なります。
if (GetOsType() == "unix") {
  volume_root <- "/Volumes"
  move_path <- '~/Library/CloudStorage/Box-Box/Datacenter/ISR/"Attendance Management"/'
} else {
  volume_root <- "//aronas"
  move_path <- '~/Box/Datacenter/ISR/"Attendance Management/"'
}

# 入力CSVの親フォルダ（ネットワークドライブ上）
input_root <- file.path(volume_root, "Archives", "Log", "DC入退室", "rawdata")
# 出力先の親フォルダ（プロジェクト内 output/）
output_root <- here("output")

# ------ 除外する「状況」の値 ------
# これらの行は出退勤集計から除きます。
EXCLUDE_STATUS <- c("ﾃﾞｰﾀ設定成功(利用者情報)", "通行ﾚﾍﾞﾙｴﾗｰ")

# ------ メイン処理 ------
yyyymm <- GetTargetYyyymm()
input_dir <- file.path(input_root, yyyymm)
output_dir <- file.path(output_root, yyyymm)

if (!dir.exists(output_dir)) dir.create(output_dir)

# 入力CSVを読み込んで結合し、不要行を除去する
csv_files <- list.files(input_dir, full.names = TRUE, pattern = "\\.csv$")
df_attendance <- map(csv_files, ReadCsvFunc) |>
  bind_rows() |>
  rename(name = 名前) |>
  filter(name != "", !状況 %in% EXCLUDE_STATUS) |>
  mutate(
    ymd  = as.Date(日時),
    time = format(as.POSIXct(日時), "%H:%M:00")
  )

# 月の全日付テーブル（出勤実績がない日も行として出力するために使用）
df_calendar <- CreateCalendar(yyyymm)

# 個人ごとに出勤（最小時刻）・退勤（最大時刻）を集計してファイルに書き出す
name_list <- df_attendance |>
  distinct(name) |>
  arrange(name) |>
  pull(name)

walk(name_list, function(target_name) {
  df_person <- df_attendance |>
    filter(name == target_name) |>
    group_by(ymd)

  df_clockin <- df_person |>
    filter(time == min(time)) |>
    distinct(ymd, .keep_all = TRUE) |>
    select(name, ymd, clockin = time)

  df_clockout <- df_person |>
    filter(time == max(time)) |>
    distinct(ymd, .keep_all = TRUE) |>
    select(name, ymd, clockout = time)

  df_output <- full_join(df_clockin, df_clockout, by = c("name", "ymd")) |>
    right_join(df_calendar, by = "ymd") |>
    arrange(ymd) |>
    ungroup() |>
    select(clockin, clockout)

  # ファイル名から数字・空白を除去（除去後が空になる場合は元の名前を使用）
  file_name <- str_replace_all(target_name, "[0-9\\s　]", "")
  if (file_name == "") file_name <- target_name

  write.table(df_output, file.path(output_dir, paste0(file_name, ".txt")),
    sep = "\t", na = "", row.names = FALSE, col.names = FALSE,
    fileEncoding = "cp932"
  )
})

# ------ 出力フォルダを Box に移動 ------
# テストモード（test_mode = TRUE）では移動をスキップします。
if (!isTRUE(test_mode)) {
  MoveFile("-n", output_root, move_path, paste0(yyyymm, "/"))
}
