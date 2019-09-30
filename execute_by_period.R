start_ymd <- "2016-4-1"
end_ymd <- as.Date(format(Sys.Date(), "%Y-%m-01")) - 1
input_str_yyyymm <- seq(as.Date(start_ymd), end_ymd, by = "months")
input_str_yyyymm <- paste0(substring(input_str_yyyymm, 1, 4), substring(input_str_yyyymm, 6, 7))
for (i in 1:length(input_str_yyyymm)){
  target_yyyymm <- input_str_yyyymm[i]
  source("/Users/admin/Documents/GitHub/attendance_management/attendance_management.R")
}
