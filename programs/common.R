#' @file common.R
#' @author Mariko Ohtsuka
#' @date 2021.12.3
# ------ libraries ------
library(tidyverse)
library(hms)
library(xts)
# ------ functions ------
#' @title ReadCsvFunc
#' @param input_csv
#' @return If the first column name is "日時", return CSV data, otherwise return NULL
#' @example temp <- ReadCsvFunc(file_list[i])
ReadCsvFunc <- function(input_csv){
  temp <- read.csv(input_csv, skip=3, fileEncoding="cp932", stringsAsFactors=F, na.strings = "NA")
  if (colnames(temp)[1] == "日時") {
    return(temp)
  } else {
    return(NULL)
  }
}
#' @title GetMonthLastDate
#' @param yyyymm A character
#' @return Last day of month of param
#' @example GetMonthLastDate(yyyymm)
GetMonthLastDate <- function(yyyymm){
  yyyy <- str_sub(yyyymm, 1, 4)
  mm <- str_sub(yyyymm, 5, 7)
  if (mm == 12){
    yyyy <- as.character(as.integer(yyyy) + 1)
    mm <- "01"
  } else {
    mm <- as.character(as.integer(mm) + 1)
  }
  next_month <- as.Date(str_c(yyyy, mm, "01", sep="-"))
  return(format(next_month - 1, "%d"))
}
#' @title GetYyyymm
#' @param none.
#' @return Year and month string, for example, "202112".
GetYyyymm <- function(){
  if (exists("target_yyyymm", envir=.GlobalEnv)){
    yyyymm <- target_yyyymm
  } else{
    # target the previous month of the execution date
    yyyymm <- Sys.Date() %>% format("%Y-%m-01") %>% as.Date() %>% {. - 1} %>% format("%Y%m")
  }
  return(yyyymm)
}
#' @title GetOsType
#' @description Get the OS type.
#' @param none.
#' @return A string of 'windows' or 'unix'.
GetOsType <- function(){
  os <- .Platform$OS.type  # mac or windows
  return(os)
}
#' @title RemoveLastBackslash
#' @description If the string of the specified file path ends with '\', remove the '\'.
#' @param input_path The path string.
#' @return String of the path with trailing backslashes removed.
RemoveLastBackslash <- function(input_path){
  temp_path <- ifelse(substr(input_path, nchar(input_path), nchar(input_path)) == '/',
                      substr(input_path, 1, nchar(input_path) - 1),
                      input_path)
  return(temp_path)
}
#' @title DetermineFileOrFolderByPath
#' @description If the argument ends with a backslash, it is determined to be a directory. Otherwise, it assumes it is a file.
#' @param input_path The path to input.
#' @return boolean T:Folder, F:File.
DetermineFileOrFolderByPath <- function(input_path){
  res <- ifelse(str_sub(input_path, -1) == '/', T, F)
  return(res)
}
#' @title CheckAlreadyExist
#' @description Determines if a folder or file exists at the specified path.
#' @param target_path The path to check.
#' @param check_name Name of the folder or file to be checked.
#' @return boolean T: exist, F: not exist.
CheckAlreadyExist <- function(target_path, check_name){
  temp_path <- RemoveLastBackslash(target_path)
  if (DetermineFileOrFolderByPath(check_name)){
    temp <- target_path %>% list.dirs(recursive=F, full.names=F)
  } else {
    temp <- target_path %>% list.files(recursive=F, full.names=F)
  }
  check <- any(temp == RemoveLastBackslash(check_name))
  res <- ifelse(check, T, F)
  return(res)
}
#' @title MoveFile
#'
#' @param option_str A string of command options. Set '' if it is not needed.
#' @param from_path Source path.
#' @param to_path Destination path.
#' @param target_name Name of the folder or file to be moved.
#' @return none.
#' @example MoveFile('-n', '~/Downloads/', '~/Documents/', 'aaaa/')
MoveFile <- function(option_str, from_path, to_path, target_name){
  exec_f <- T
  if (GetOsType() == 'unix'){
    if (option_str == '-n'){
      if (CheckAlreadyExist(to_path, target_name)){
        exec_f <- F
        stop('The move will not be executed because a folder with the same name already exists.')
      }
      if (exec_f){
        system(str_c('mv ', option_str, ' ', RemoveLastBackslash(from_path), '/', target_name, ' ', RemoveLastBackslash(to_path), '/'))
      }
    }
  } else {
    # for windows
  }
}
