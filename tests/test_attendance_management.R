# test_attendance_management.R
# attendance_management.R の出力が既存の期待値と一致するか検証します。
# 使い方:
#   1. output/test_202401 に期待値ファイルが存在することを確認してください。
#   2. このスクリプトを Source してください。
#   3. コンソールに PASS / FAIL が表示されます。
# ------ libraries ------
library(here)
library(tidyverse)
# ------ settings ------
# テスト対象の年月（期待値フォルダ名に合わせる）
test_yyyymm <- "202605"
# テストモードを有効にしてから attendance_management.R を実行する
# （MoveFile がスキップされ、本番データが書き換えられるのを防ぐ）
test_mode      <- TRUE
target_yyyymm  <- test_yyyymm
source(here("programs", "attendance_management.R"), encoding="utf-8")
test_mode <- FALSE
# 期待値フォルダ（git管理下の既存出力）
expected_dir <- here("output", str_c("test_", test_yyyymm))
# 生成結果フォルダ（attendance_management.R が出力したフォルダ）
actual_dir   <- here("output", test_yyyymm)
# ------ helper ------
read_txt <- function(path){
  # cp932 で読み込み、行ごとの文字列として返す
  readLines(path, encoding="cp932", warn=FALSE)
}
compare_file <- function(filename){
  exp_path <- file.path(expected_dir, filename)
  act_path <- file.path(actual_dir,   filename)
  if (!file.exists(act_path)){
    return(list(pass=FALSE, reason=paste("出力ファイルが存在しません:", filename)))
  }
  exp <- read_txt(exp_path)
  act <- read_txt(act_path)
  if (identical(exp, act)){
    return(list(pass=TRUE, reason=""))
  } else {
    diff_lines <- which(exp != act)
    return(list(pass=FALSE, reason=paste0(filename, " - 差異あり (行: ", paste(diff_lines, collapse=","), ")")))
  }
}
# ------ run test ------
cat("=== テスト開始 ===\n")
cat("期待値:", expected_dir, "\n")
cat("実際値:", actual_dir, "\n\n")
if (!dir.exists(expected_dir)){
  stop("期待値フォルダが存在しません: ", expected_dir)
}
if (!dir.exists(actual_dir)){
  stop("出力フォルダが存在しません。先に attendance_management.R を実行してください: ", actual_dir)
}
expected_files <- list.files(expected_dir, pattern="\\.txt$")
if (length(expected_files) == 0){
  stop("期待値フォルダにtxtファイルがありません。")
}
results <- map(expected_files, compare_file)
pass_count <- sum(map_lgl(results, ~ .x$pass))
fail_count <- length(results) - pass_count
for (i in seq_along(results)){
  r <- results[[i]]
  if (!r$pass){
    cat("FAIL:", r$reason, "\n")
  }
}
# 出力フォルダにあって期待値にないファイルを検出
actual_files <- list.files(actual_dir, pattern="\\.txt$")
extra_files  <- setdiff(actual_files, expected_files)
if (length(extra_files) > 0){
  cat("WARNING: 期待値に存在しない出力ファイルがあります:", paste(extra_files, collapse=", "), "\n")
}
cat("\n=== 結果 ===\n")
cat(sprintf("PASS: %d / %d\n", pass_count, length(results)))
if (fail_count == 0 && length(extra_files) == 0){
  cat("全ファイル一致しました。\n")
} else {
  cat(sprintf("FAIL: %d ファイルに差異があります。\n", fail_count))
}
