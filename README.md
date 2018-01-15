# SocMed_Crawler
Crawls Twitter via its stream API and Facebook search API
Twitter Crawler only need to be run once as it will run forever. It will get any tweets containing keywords telkomsel, tsel and @telkomsel.
Every 5 minutes, if there are any tweets mentioning "slow connection", a Telegram bot will send the tweets to my Telegram account.
Since its using streaming API, it will collect all tweets.

Facebook crawler is using search API thus not so comprehensive as Twitter streaming API.
The code collect past 30 days posts from XL, Indosat and Telkomsel facebook fanpage account.
All comments from those posts were also collected.
