require 'cgi'
require 'MeCab'
require 'kconv'
require 'rubygems'
require 'sqlite3'
require 'open-uri'
require 'hpricot'
require 'mechanize'
require 'bot/twitterapi'
require 'bot/botconst'
require 'bot/daemon'
require 'bot/marcov'

module Bot
  $const = Bot::BotConst.new
  $con = SQLite3::Database.new($const.DB)

  def self.start(user, pass, sleep_time=$const.SLEEP_TIME)
    twitter_client = Bot::TwitterAPI.new(user, pass)
    chain = Chain.new
    bot = Bot::Daemon.new(twitter_client, chain)
    bot.start
  end

  def self.tl(page, tlnum=100)
    status_id = $con.execute("select status_id from friends_timeline order by status_id desc limit #{tlnum*page.to_i}").flatten[tlnum*(page.to_i-1)]
    tl = ""
    begin
      tl = $con.execute("select screen_name, text from friends_timeline where status_id<=\'#{status_id}\' order by status_id desc limit #{tlnum}")
    rescue SQLite3::SQLException
    end
    tl
  end

  def self.update(user, pass, comment)
    twitter_client = Bot::TwitterAPI.new(user, pass)
    twitter_client.update(comment)
  end

  def self.createtable
    begin
      $con.execute('create table friends_timeline(status_id, screen_name, created_at, text)')
      $con.execute('create table learn_ngram(word, next, last, score)')
    rescue SQLite3::SQLException
      "tables already exist"
    end
  end
end
