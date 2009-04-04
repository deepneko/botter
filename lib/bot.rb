require 'cgi'
require 'kconv'
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

  $form = <<"FORM"
What are you doing?<br>
<form action="./twitter.cgi" method="get">
<input type="text" name="comment"><br>
<input type="submit" value="update">
</form>
<hr>
FORM

  def self.start(user, pass, sleep_time=$const.SLEEP_TIME)
    twitter_client = Bot::TwitterAPI.new(user, pass)
    bot = Bot::Daemon.new(twitter_client)
    #1.upto($const.PAGE_HISTORY) do |page|
    #  p twitter_client.friends_timeline(page, 897098556)
    #end
    bot.start
  end

  def self.tl(page=1, tlnum=100)
    status_id = $con.execute("select status_id from friends_timeline order by status_id desc limit #{tlnum*page}").flatten[tlnum*(page-1)]
    tl = ""
    begin
      tl = $con.execute("select screen_name, text from friends_timeline where status_id<=\'#{status_id}\' order by status_id desc limit #{tlnum}")
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
