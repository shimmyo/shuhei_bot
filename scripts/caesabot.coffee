# Description:
#   caesabot helps to enjoy slack life
#
# Dependencies:
#   $ npm install
#
# Configuration:
#   You need to set following environment variables
#     HUBOT_SLACK_TOKEN
#     HUBOT_IRKIT_CLIENT_KEY
#     HUBOT_IRKIT_DEVICE_ID
#     HUBOT_IRKIT_OWNER_01
#     HUBOT_TEMPERATURE_API_KEY
#
# Commands:
#   sarubo help          -- Display this help
#   sarubo ping          -- Check whether a bot is alive
#   sarubo weather       -- Ask today's weather
#   sarubo yahoo-news    -- Display current yahoo news highlight
#   sarubo kindle        -- Display daily kindle sale book
#   sarubo train         -- Display train status
#   sarubo say [SOMETHING]       -- Yamada-bot say SOMETHING in #general
#   sarubo ping [IPADDR]         -- Execute ping [IPADDR] from bot
#   sarubo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot
#   sarubo whois [IPADDR]        -- Execute whois [IPADDR]
#   sarubo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
#
# Author:
#   noralife
#

cheerio = require('cheerio')
cheerio-httpcli = require('cheerio-httpcli')
cron = require('cron').CronJob
request = require('request')

module.exports = (robot) ->


  robot.respond /help/i, (res) ->
    res.send '''
```
sarubo help          -- Display this help
sarubo ping          -- Check whether a bot is alive
sarubo weather       -- Ask today's weather
sarubo yahoo-news    -- Display current yahoo news highlight
sarubo kindle        -- Display daily kindle sale book
sarubo train         -- Display train status
sarubo emotion [SOMETHING]   -- Analyze [SOMETHING] using emotion API
sarubo ping [IPADDR]         -- Execute ping [IPADDR] from bot server
sarubo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
sarubo whois [IPADDR]        -- Execute whois [IPADDR]
sarubo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
```
              '''

  # example for shell execution

#  robot.respond /debug/, (msg) ->
#    console.log msg
#    console.log msg.message
#    console.log msg.message.user

  IRKIT_MESSAGE_API = "http://api.getirkit.com/1/messages/"
  IRKIT_OWNER_01 = process.env.HUBOT_IRKIT_OWNER_01
  IRKIT_CLIENT_KEY = process.env.HUBOT_IRKIT_CLIENT_KEY
  IRKIT_DEVICE_ID = process.env.HUBOT_IRKIT_DEVICE_ID
  TV_POWER = '{"format":"raw","freq":38,"data":[4713,1190,2368,1150,1150,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,50610,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,50610,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,50610,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,50610,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150]}'
  TV_NHK = '{"format":"raw","freq":38,"data":[4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,54214,4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,54214,4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,54214,4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,54214,4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,54214,4713,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150]}'
  TV_TBS = '{"format":"raw","freq":38,"data":[4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,2368,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150]}'
  TV_TOKYO = '{"format":"raw","freq":38,"data":[4713,1190,1190,1190,2288,1275,2288,1275,1275,1275,1111,1232,1111,1232,1111,1232,2288,1275,1073,1232,1073,1232,1073,1232,1073,52381,4713,1232,1111,1232,2288,1232,2288,1232,1073,1275,1073,1275,1073,1275,1073,1275,2288,1190,1190,1190,1073,1232,1073,1232,1073,52381,4713,1232,1111,1232,2368,1190,2368,1190,1073,1232,1073,1232,1073,1232,1073,1232,2368,1232,1111,1111,1111,1275,1111,1275,1111,52381,4713,1232,1111,1232,2288,1232,2288,1232,1232,1232,1111,1232,1111,1232,1111,1232,2288,1232,1232,1232,1073,1232,1073,1232,1073]}'
  TV_ASAHI = '{"format":"raw","freq":38,"data":[4713,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,52381,4713,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150]}'
  TV_FUJI = '{"format":"raw","freq":38,"data":[1190,1190,1190,1190,1190,1190,1190,50610,4713,1150,2368,1150,2368,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,50610,4713,1150,2368,1150,2368,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150,1150,2368,1150,1150,1150,1150,1150,1150,1150,1150]}'
  TV_MX = '{"format":"raw","freq":38,"data":[4713,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,1190,52381,4713,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,1190,52381,4713,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,1190,52381,4713,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,1190,52381,4713,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,2368,1190,1190,1190,1190,1190,1190,1190,1190]}'
  AIRCON_OFF = '{"format":"raw","freq":38,"data":[6648,3341,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,2451,873,2451,873,787,873,787,873,787,873,2451,873,787,873,787,873,2451,873,787,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,787,873,787,873,2451,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,2451,873,787,873,787,873,2451,873,787,873,2451,873,787,873,2451,873,787,873,2451,873,2451,873,787,873,2451,873,787,873,2451,873,787,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,2451,873,2451,873,787,873,2451,873,787,873,2451,873,787,873,2451,873,787,873,787,873,2451,873,787,873,2451,873,787,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873]}'
  AIRCON_COLD = '{"format":"raw","freq":38,"data":[6648,3341,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,873,787,873,787,873,787,787,787,787,787,873,2451,873,2451,873,787,787,787,873,2451,873,2451,873,2451,873,2451,873,787,873,787,787,2451,873,2451,873,787,787,787,787,787,787,2451,873,787,873,787,873,2451,873,787,787,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,787,787,787,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,2451,873,787,873,873,873,2451,873,787,787,787,787,787,787,787,787,787,873,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,787,787,873,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,787,787,787,787,787,787,787,873,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,873,787,873,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,2451,873,2451,873,873,873,787,787,787,787,787,873,2451,873,2451,873,787,787,787,787,2451,873,2451,873,2451,873,787,787,787,787,787,787,2451,873,787,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873]}'
  AIRCON_DRY = '{"format":"raw","freq":38,"data":[6648,3341,873,2451,873,787,787,787,787,787,873,787,787,787,787,787,787,787,787,787,873,787,873,787,787,787,787,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,787,873,787,787,2451,873,2451,873,2451,873,2451,873,787,787,787,787,2451,873,2451,873,787,873,787,873,787,873,2451,873,787,787,787,873,2451,873,787,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,873,2451,873,2451,873,2451,873,787,787,787,787,787,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,2451,873,787,873,787,873,2451,873,787,787,787,787,787,787,787,873,787,873,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,873,787,787,787,787,787,787,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,873,787,787,787,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,873,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,873,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,2451,873,787,873,787,873,2451,873,787,787,787,787,787,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,787,787,787,787,2451,873,787,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,873,787,787,787,873,787,873,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873]}'
  AIRCON_HOT = '{"format":"raw","freq":38,"data":[6648,3341,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,787,873,787,873,787,873,787,873,873,873,873,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,873,787,787,787,787,787,787,787,873,787,787,787,787,2451,873,2451,873,787,787,787,787,2451,873,2451,873,2451,873,2451,873,787,787,787,787,2451,873,2451,873,787,787,787,787,787,787,2451,873,787,873,787,873,2451,873,787,787,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,787,787,787,787,2451,873,2451,873,787,787,2451,873,787,873,2451,873,2451,873,2451,873,787,787,787,787,2451,873,787,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,873,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,2451,873,2451,873,787,787,2451,873,2451,873,787,787,787,787,2451,873,787,873,787,873,2451,873,787,787,787,787,2451,873,2451,873,2451,873,787,787,787,787,787,787,2451,873,787,873,2451,873,2451,873,787,787,2451,873,2451,873,2451,873,787,787,2451,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,787,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,787,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873,2451,873]}'
  AIRCON_FUNC = process.env.HUBOT_IRKIT_AIRCON_FUNC


  postIRKit = (msg, json, output) ->
    msg.http(IRKIT_MESSAGE_API)
    .query({
      clientkey: IRKIT_CLIENT_KEY
      deviceid: IRKIT_DEVICE_ID
      message: json})
    .post() (err, res, body) ->
      msg.reply output

  robot.respond /aircon (cold|dry|off|.*)/, (msg) ->
    if AIRCON_FUNC is "on"
      if msg.message.user.name is IRKIT_OWNER_01
        sw = msg.match[1]
        if sw is "cold"
          postIRKit msg, AIRCON_COLD, "冷房モードでエアコンつけたよ"
        else if sw is "dry"
          postIRKit msg, AIRCON_DRY, "除湿モードでエアコンつけたよ"
        else if sw is "off"
          postIRKit msg, AIRCON_OFF, "エアコン消しといたよ"
        else
          postIRKit msg, null, "ちょっと何言ってるかよくわからん"
      else
        msg.reply "Sorry, this command is only for <@#{IRKIT_OWNER_01}>."
    else
      msg.reply "今はそれ使えないわ"

  robot.respond /tv (power|nhk|tbs|tokyo|asahi|fuji|mx|.*)/, (msg) ->
    if msg.message.user.name is IRKIT_OWNER_01
      sw = msg.match[1]
      if sw is "power"
        postIRKit msg, TV_POWER, "テレビの電源ボタン押しちゃったわ"
      else if sw is "nhk"
        postIRKit msg, TV_NHK, "NHKにチャンネル変えたわ"
      else if sw is "tbs"
        postIRKit msg, TV_TBS, "TBSにチャンネル変えたわ"
      else if sw is "tokyo"
        postIRKit msg, TV_TOKYO, "テレ東にチャンネル変えたわ"
      else if sw is "asahi"
        postIRKit msg, TV_ASAHI, "テレ朝にチャンネル変えたわ"
      else if sw is "fuji"
        postIRKit msg, TV_FUJI, "フジテレビにチャンネル変えたわ"
      else if sw is "mx"
        postIRKit msg, TV_MX, "TOKYO MXにチャンネル変えたわ"
      else
        postIRKit msg, null, "そのチャンネルは知らん"
    else
      msg.reply "Sorry, this command is only for <@#{IRKIT_OWNER_01}>."

  robot.respond /ping(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "PONG"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "ping #{ip_addr} -c 5", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"
      else
        msg.send "Omae IPv4 address mo wakaranaino"

  robot.respond /traceroute(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "IPv4 address wo iretene"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "traceroute #{ip_addr}", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"
      else
        msg.send "Omae IPv4 address mo wakaranaino"

  robot.respond /whois(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "IPv4 address wo iretene"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "whois #{ip_addr}", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"

  getWeather = (callback) ->
    options = {
      url: 'http://weather.livedoor.com/forecast/webservice/json/v1?city=130010',
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        weathers = []
        for forecast in json.forecasts
          weather = []
          weather["telop"] = forecast.telop
          weather["maxtemp"] = forecast.temperature.max.celsius if forecast.temperature.max?
          weather["mintemp"] = forecast.temperature.min.celsius if forecast.temperature.min?
          weathers.push weather
        callback(weathers)
      else
        console.log('error: '+ response.statusCode)

  getKindleBook = (callback) ->
    cheerio-httpcli.fetch 'http://www.amazon.co.jp/b?node=3338926051', {}, (err, $, res)->
      book =  $('h3').text()
      callback(book)

  getYahooNews = (callback) ->
    cheerio-httpcli.fetch 'http://www.yahoo.co.jp/', {}, (err, $, res)->
      items = []
      $('ul.emphasis > li > a').each ()->
        items.push($(this).text())
      callback(items)

  getDelayedTrain = (callback) ->
    cheerio-httpcli.fetch 'http://api.tetsudo.com/traffic/atom.xml?kanto', {}, (err, $, res)->
      trains = []
      $('entry > title').each ()->
        if /JR東日本|東京メトロ|都営地下鉄|東武鉄道|西武鉄道|京成電鉄|京王電鉄|小田急電鉄|東急電鉄|京急電鉄|横浜市営地下鉄|りんかい線|つくばエクスプレス|ゆりかもめ|東京モノレール|日暮里・舎人ライナー/.test($(this).text())
          trains.push($(this).text())
      callback(trains)

  isHoliday = (holidayCallback, elseCallback) ->
    cheerio-httpcli.fetch 'http://s-proj.com/utils/checkHoliday.php?kind=h&opt=gov', {}, (err, $, res)->
      date = res.body.toString('utf-8')
      if date is 'holiday'
        holidayCallback()
      else
        elseCallback()

  getTemperature = (tooColdCallback, tooHotCallback, normalTempCallback) ->
    apikey = process.env.HUBOT_TEMPERATURE_API_KEY
    options = {
      url: 'http://api.openweathermap.org/data/2.5/weather?id=1850147&appid=' + apikey,
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        currentTemp = json.main.temp - 273.15
        if currentTemp < 10
          tooColdCallback(currentTemp)
        else if currentTemp >= 20
          tooHotCallback(currentTemp)
        else
          normalTempCallback(currentTemp)
      else
        console.log('error: '+ response.statusCode)

  getCurrentTemp = (callback) ->
    apikey = process.env.HUBOT_TEMPERATURE_API_KEY
    options = {
      url: 'http://api.openweathermap.org/data/2.5/weather?id=1850147&appid=' + apikey,
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        currentTemp = Math.round((json.main.temp - 273.15)*10) / 10
        callback(currentTemp)
      else
        console.log('error: '+ response.statusCode)

  # example for calling API
  robot.respond /weather/i, (msg) ->
    getWeather (weathers) ->
      console.log(weathers)
      message = "今日の天気は#{weathers[0]['telop']}ですね。"
      message += "最高気温は#{weathers[0]['maxtemp']}度だそうです。" if weathers[0]['maxtemp']?
      message += "\nちなみに明日は#{weathers[1]['telop']}になるみたいですよ。"
      msg.send message

  robot.respond /temp/i, (msg) ->
    getCurrentTemp (currentTemp) ->
      msg.send "今の東京の気温は、#{currentTemp}℃です。"

  # example for scraping
  robot.respond /yahoo-news/i, (msg) ->
    getYahooNews (items) ->
      msg.send "Yahoo Newsですか？どうぞ。詳細は自分でチェックしてくださいね。"
      for item in items
        msg.send "・#{item}"

  robot.respond /kindle/i, (msg) ->
    getKindleBook (book) ->
      msg.send "今日のKindle日替わりセール本は「#{book}」です。でもせっかくならひかりＴＶブックで読みませんか？"

  robot.respond /say (.*)/i, (msg) ->
    robot.send {room: "#general"}, msg.match[1].trim()

  robot.respond /train/i, (msg) ->
    getDelayedTrain (trains) ->
      if trains.length > 0
        msg.send "遅れてる電車ですか？こちらです。"
        for train in trains
          msg.send "・#{train}"
      else
        msg.send "遅延は特にないようです。"

  addReaction = (name, ch, ts, callback) ->
    options = {
      url: 'https://slack.com/api/reactions.add'
      qs: {
        'token': process.env.HUBOT_SLACK_TOKEN
        'name': name
        'channel': ch
        'timestamp': ts
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        robot.logger.error("Failed to add emoji reaction #{JSON.stringify(err)}")

  postMessage = (msg, text, callback) ->
    options = {
      url: 'https://slack.com/api/chat.postMessage'
      qs: {
        'token': process.env.HUBOT_SLACK_TOKEN
        'channel': msg.message.rawMessage.channel
        'text': text
        'username': 'caesabot'
        'as_user': true
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        robot.logger.error("Failed to post comment #{JSON.stringify(err)}")

  postMessages = (msg, texts) ->
    text = texts.shift()
    if text?
      postMessage msg, text, (body) ->
        addReactions(["+1", "scream"], body.channel, body.ts)
        postMessages(msg, texts)

  addReactions = (names, ch, ts) ->
    name = names.shift()
    if name?
      addReaction name, ch, ts, (body) ->
        addReactions names, ch, ts

  robot.respond /vote (.*)/i, (msg) ->
    params = msg.match[1].trim().split(" ")
    title = params[0]
    items = params.slice(1).join(" ").split(",")
    msg.send "#{title}の投票するよ"
    msg.send "集計するときは-1を忘れずに(caesabotを除く)"
    msg.send "-----------------------------------------"
    postMessages msg, items

  robot.hear /ぬるぽ/, (msg) ->
    msg.reply """
```
   Λ＿Λ     ＼＼
（  ・∀・）  | | ｶﾞｯ
 と     ）  | |
  Ｙ /ノ     人
   / ）    < >   _Λ  ∩
＿/し'   ／／  Ｖ｀Д´）/
（＿フ彡             /
```
  """


  # cron
  new cron '00 00 18 * * 5', () ->
    isHoliday () ->
      null
    , () ->
      robot.send {room: "#general"}, "今日は金曜日ですし、そろそろ帰りましょう。よい週末を！"
  , null, true, "Asia/Tokyo"

  new cron '00 45 06 * * 0-6', () ->
    if AIRCON_FUNC is "on"
      getTemperature () ->
        #tooColdCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_HOT})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "暖房いれておいたよ"
      , () ->
        #tooHotCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_COLD})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "冷房いれておいたよ"
      , () ->
        #normalTempCallback
        null
    else
      null
  , null, true, "Asia/Tokyo"


  new cron '00 30 19 * * 0-6', () ->
    if AIRCON_FUNC is "on"
      getTemperature () ->
        #tooColdCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_HOT})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "暖房いれておいたよ"
      , () ->
        #tooHotCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_COLD})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "冷房いれておいたよ"
      , () ->
        #normalTempCallback
        null
    else
      null
  , null, true, "Asia/Tokyo"

  new cron '00 15 08 * * 1-5', () ->
    isHoliday () ->
      null
    , () ->
      robot.http(IRKIT_MESSAGE_API)
        .query({
          clientkey: IRKIT_CLIENT_KEY
          deviceid: IRKIT_DEVICE_ID
          message: AIRCON_OFF})
        .post() (err, res, body) ->
          robot.send {room: "#{IRKIT_OWNER_01}"}, "そろそろ会社いく時間だぞ。早く出なよ。"
  , null, true, "Asia/Tokyo"

#  new cron '00 30 12 * * 0-6', () ->
#    isHoliday () ->
#      robot.http(IRKIT_MESSAGE_API)
#        .query({
#          clientkey: IRKIT_CLIENT_KEY
#          deviceid: IRKIT_DEVICE_ID
#          message: AIRCON_OFF})
#        .post() (err, res, body) ->
#          robot.send {room: "#{IRKIT_OWNER_01}"}, "休みとは言え、少しは外に出たら？"
#    , () ->
#      null
#  , null, true, "Asia/Tokyo"


  new cron '00 45 23 * * 0-6', () ->
    if AIRCON_FUNC is "on"
      getTemperature () ->
        #tooColdCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_OFF})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "そろそろ寝た方がよくない？おやすみ！"
      , () ->
        #tooHotCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_DRY})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "そろそろ寝た方がよくない？エアコンは除湿にしておくわ。"
      , () ->
        #normalTempCallback
        robot.http(IRKIT_MESSAGE_API)
          .query({
            clientkey: IRKIT_CLIENT_KEY
            deviceid: IRKIT_DEVICE_ID
            message: AIRCON_OFF})
          .post() (err, res, body) ->
            robot.send {room: "#{IRKIT_OWNER_01}"}, "そろそろ寝た方がよくない？おやすみ！"
    else
      null
  , null, true, "Asia/Tokyo"
