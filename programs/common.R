# common.R
# author: Mariko Ohtsuka
# date: 2026/6/15

# ------ libraries ------
library(tidyverse)
library(lubridate)
# ------ functions ------

#' 入退室ログCSVを1ファイル読み込む
#'
#' @param csv_path CSVファイルのパス
#'
#' @return 先頭列が "日時" であるデータフレーム。対象外ファイルは NULL を返す
ReadCsvFunc <- function(csv_path) {
  df <- read.csv(csv_path,
    skip = 3, fileEncoding = "cp932",
    stringsAsFactors = FALSE, na.strings = "NA"
  )
  if (colnames(df)[1] != "日時") {
    return(NULL)
  }
  return(df)
}

#' 指定年月のカレンダー（全日付）データフレームを作成する
#'
#' @param yyyymm 年月文字列（例: "202401"）
#'
#' @return ymd 列を持つデータフレーム
CreateCalendar <- function(yyyymm) {
  first_day <- ymd(str_c(yyyymm, "01"))
  last_day <- first_day + months(1) - days(1)
  data.frame(ymd = seq(first_day, last_day, by = "day"), stringsAsFactors = FALSE)
}

#' 処理対象の年月を取得する
#'
#' @description
#' グローバル変数 target_yyyymm が定義されていればその値を使用する。
#' 定義されていない場合は実行日の前月を返す。
#'
#' @return 年月文字列（例: "202401"）
GetTargetYyyymm <- function() {
  if (exists("target_yyyymm", envir = .GlobalEnv)) {
    return(target_yyyymm)
  }
  return(format(floor_date(Sys.Date(), "month") - days(1), "%Y%m"))
}

#' OS種別を返す
#'
#' @return "unix"（Mac/Linux）または "windows"
GetOsType <- function() {
  return(.Platform$OS.type)
}

#' パス末尾のスラッシュを除去する
#'
#' @description Mac（/）・Windows（\\）両対応。
#'
#' @param path パス文字列
#'
#' @return 末尾スラッシュを除いたパス文字列
RemoveLastSlash <- function(path) {
  if (substr(path, nchar(path), nchar(path)) %in% c("/", "\\")) {
    return(substr(path, 1, nchar(path) - 1))
  }
  return(path)
}

#' フォルダまたはファイルを移動する
#'
#' @param option_str オプション文字列。"-n" を指定すると移動先に同名が存在する場合はエラーで停止する
#' @param from_path  移動元の親フォルダパス
#' @param to_path    移動先の親フォルダパス
#' @param target_name 移動するフォルダ名またはファイル名
#'
#' @return NULL（副作用としてファイルを移動する）
MoveFile <- function(option_str, from_path, to_path, target_name) {
  from <- file.path(RemoveLastSlash(from_path), RemoveLastSlash(target_name))
  to <- file.path(RemoveLastSlash(to_path), RemoveLastSlash(target_name))

  if (option_str == "-n" && file.exists(to)) {
    stop("移動先に同名のフォルダが既に存在するため、移動を中止しました: ", to)
  }
  if (!file.exists(from)) {
    stop("移動元が見つかりません: ", from)
  }

  success <- file.rename(from, to)
  if (!success) {
    # デバイスをまたぐ移動（file.rename 非対応）の場合はコピー後に削除
    if (dir.exists(from)) {
      dir.create(to, recursive = TRUE, showWarnings = FALSE)
      files <- list.files(from, full.names = TRUE, recursive = TRUE)
      file.copy(files, sub(from, to, files, fixed = TRUE), recursive = TRUE)
      unlink(from, recursive = TRUE)
    } else {
      file.copy(from, to)
      file.remove(from)
    }
  }
}
