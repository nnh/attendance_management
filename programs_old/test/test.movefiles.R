#' title
#' description
#' @file xxx.R
#' @author Mariko Ohtsuka
#' @date YYYY.MM.DD
rm(list=ls())
# ------ set date if necessary ------
#target_yyyymm <- "201906"
# ------ libraries ------
library(RUnit)
library(here)
source(here('programs', 'common.R'), encoding='utf-8')
# ------ unit test ------
'*** existent file ***' %>% print()
CheckAlreadyExist('~/.config/rstudio/snippets/','r.snippets') %>% checkTrue()
'*** existent dir ***' %>% print()
CheckAlreadyExist('~/.config/rstudio/','snippets/') %>% checkTrue()
'*** Non-existent file ***' %>% print()
CheckAlreadyExist('~/.config/rstudio/snippets/','tests') %>% isFALSE() %>% checkTrue()
'*** Non-existent dir ***' %>% print()
CheckAlreadyExist('~/.config/rstudio/snippets/','r.snippets/') %>% isFALSE() %>% checkTrue()
' *** Folder copy (success) ***' %>% print()
MoveFile('-n', '~/Downloads/', '~/Documents/', 'aaaa/')
system('cp -r ~/Documents/aaaa/ ~/Downloads/aaaa/')
' *** Folder copy (failed) ***' %>% print()
MoveFile('-n', '~/Downloads/', '~/Documents/', 'aaaa/')
' *** File copy (success) ***' %>% print()
MoveFile('-n', '~/.config/rstudio/snippets/', '~/Documents/', 'r.snippets')
system('cp ~/Documents/r.snippets ~/.config/rstudio/snippets/')
' *** Folder copy (failed) ***' %>% print()
MoveFile('-n', '~/Downloads/', '~/Documents/', 'aaaa/')
