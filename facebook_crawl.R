#library(devtools)
#install_github("pablobarbera/Rfacebook/Rfacebook")
library(Rfacebook)
library(dplyr)
library(lubridate)

setwd("path to current file location")
# fb_oauth <- fbOAuth(app_id="app_id", app_secret="app_secret",extended_permissions = TRUE)
# 
# save(fb_oauth, file="fb_oauth")

load("fb_oauth")
me <- getUsers("telkomsel",token=fb_oauth)
#initial run: get id's from 30 day back
# telkomsel, myxl, XL Axiata, XLPRIORITAS, IM3Ooredoo,indosatooredoobusiness
pages = c("157697287618387", "191211482752", "1641351996126831", "39935792947","1718428065101168")
all_operator_list = list()
for(j in 1:length(pages)){
  me_page_i = getPage(pages[j], fb_oauth, feed = T, n=10000, api = "v2.6", since = Sys.Date()-3, until = Sys.Date())
  print(paste("done getting post for", pages[j]))
  if(nrow(me_page_i)==0) next
  me_page_i = me_page_i[,c(1,2,3,4,9,10,7)]
  me_page_i$type = "wall_post"
  komen = list()
  print(paste("getting comments for", pages[j]))
  for(i in 1:nrow(me_page_i)){
    temp = getPost(me_page_i$id[i], token = fb_oauth, n=10000, likes = F)
    komen[[i]] = temp$comments
    cat(paste("Processed",i, "with", nrow(komen[[i]])))
    cat("\n")
  }
  komen = bind_rows(komen)
  komen$type = "comment"
  allkomen = bind_rows(me_page_i,komen)
  allkomen$operator = ifelse(pages[j]=="157697287618387", "Telkomsel", 
                             ifelse(pages[j] %in% c("191211482752","1641351996126831"), "XL Axiata", "Indosat Ooredoo"))
  all_operator_list[[j]] = allkomen
}
all_operator = bind_rows(all_operator_list)

# get certain date data only

get_data = function(d_date){
  today_komen = filter(all_operator, as.Date(ymd_hms(created_time)+7*60*60)==d_date)
  return(today_komen)
}
my_dat = get_data(Sys.Date())
my_dat = get_data(ymd("2018-01-12"))
