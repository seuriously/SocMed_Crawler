library(rtweet)
library(dplyr)
library(telegram)


Sys.getenv()
#setwd("path to current file location")
# ## api key (example below is not a real key)
# key <- "uUKTei1kwwp2tvogrOOE6khLV"
# 
# ## api secret (example below is not a real key)
# secret <- "FtyNI9lXz8k87sW5Zy6G4WxJocbmyP0Plqz5YJ4mHBmh8csutn"
# 
# ## create token named "twitter_token"
# twitter_token <- create_token(
#   app = appname,
#   consumer_key = key,
#   consumer_secret = secret)
# home_directory <- path.expand("~/")
# cat(paste0("TWITTER_PAT=", getwd(), "/twitter_token.rds"),
#     file = file.path(home_directory, ".Renviron"),
#     append = TRUE)
# 
# ## whatever name you assigned to your created app
# appname <- "pengeruk_twit"
# 
# telegram settings
# user_renviron = path.expand(file.path("~", ".Renviron"))
# if(!file.exists(user_renviron)) # check to see if the file already exists
#   file.create(user_renviron)
# file.edit(user_renviron) # open with another text editor if this fails


bot <- TGBot$new(token = bot_token('tsel_complain_detector'))
bot$getMe()
bot$getUpdates()
bot$set_default_chat_id(user_id('me'))
bot$sendMessage('I need server')

while(T){
  stream = stream_tweets2(q = "telkomsel,tsel,@Telkomsel", timeout = 300, parse = T)
  cat("\nFinish Crawling\n")
  if(!is.null(nrow(stream))){
    stream_ = stream[,c("user_id", "created_at", "screen_name","text")]
    followers = lookup_users(unique(stream_$screen_name))
    followers_ = followers[,c("user_id", "followers_count", "friends_count", "statuses_count")]
    stream_ = stream_ %>% filter(tolower(screen_name) != "telkomsel")
    stream_ = stream_[-which(grepl(pattern = "Telkomsel:", x = stream_$text)),]
    stream_follower = left_join(stream_, followers_, by = c("user_id" = "user_id"))
    stream_follower = filter(stream_follower, followers_count>100)
    pattern = "si[ng][yn]al.+lemot|si[ng][yn]al.jelek|si[ng][yn]al.ilang|anjing|lemot|jaringan.+lemot|si[ng][yn]al.+lelet|jaringan.+lelet|lelet"
    indeks = which(grepl(pattern = pattern, ignore.case = T, x = stream_follower$text))
    if(length(indeks)>0){
      stream_follower = stream_follower[indeks, c(-1,-7)]
      toTele = paste0("User ", stream_follower$screen_name,
                      " with ", stream_follower$followers_count, " followers ",
                      "tweets: ", stream_follower$text,
                      " at ", stream_follower$created_at,collapse = "\n\n")
      bot$sendMessage(toTele)
    }
  }
}

