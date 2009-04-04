require 'cgi'
require 'rubygems'
require 'sqlite3'
require 'open-uri'
require 'hpricot'
require 'mechanize'
require 'bot/twitterapi'
require 'bot/botconst'
require 'bot/daemon'

module Bot
  $const = Bot::BotConst.new
  $con = SQLite3::Database.new($const.DB)

  def self.start(user, pass, sleep_time=$const.SLEEP_TIME)
    twitter_client = Bot::TwitterAPI.new(user, pass)
    bot = Bot::Daemon.new(twitter_client)
    #1.upto($const.PAGE_HISTORY) do |page|
    #  p twitter_client.friends_timeline(page, 897098556)
    #end
    bot.start
  end

  def self.tl(page, tlnum=100)
    rowid = $con.execute("select rowid from friends_timeline order by rowid desc limit 1").flatten.join.to_i
    tl = ""
    begin
      tl = $con.execute("select screen_name, text from friends_timeline where rowid<=\'#{rowid-tlnum*page}\' order by rowid desc limit #{tlnum}")
    rescue SQLite3::SQLException
    end
    tl
  end

  def self.createtable
    begin
      $con.execute('create table friends_timeline(status_id, screen_name, created_at, text)')
      #$con.execute('create table update(status_id, reply_to)')
    rescue SQLite3::SQLException
      "tables already exist"
    end
  end
end
