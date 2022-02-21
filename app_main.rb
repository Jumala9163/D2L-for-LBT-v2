require 'line/bot'
require 'discordrb'
require 'net/http'
require 'uri'
require 'json'

token = ENV["DISCORD_BOT_TOKEN"]
clientID = ENV["DISCORD_CLIENT_ID"]

bot = Discordrb::Commands::CommandBot.new token: token, client_id: clientID, prefix:'/'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

# messageと送信者名を合わせる
def add_message(str1, str2)
  return str1 + "\n" + '[' + str2 + ']'
end

bot.message do |event|
channel = event.channel.id
if channel == <ここにBOTが反応して欲しいDiscordのチャンネルIDを入れる>
  bot_message = event.message.content
  push_line(add_message(event.user.display_name, bot_message))
  # messageだけ送信したい場合
  # push_line(bot_message)
end
end


def push_line(message)

  uri = URI.parse("https://api.line.me/v2/bot/message/push")

  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{ENV["LINE_CHANNEL_TOKEN"]}"
  request.body = JSON.dump({
    "to" => "<ここに送信したいLineのグループIDを入れる>",
    "messages" => [
      {
        "type" => "text",
        "text" => message
      }
    ]
  })

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
  end
end

bot.run