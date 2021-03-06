module Bot
  class Daemon
    def initialize(twc, chain)
      @twitter_client = twc
      @chain = chain
    end

    # main loop
    def start
      while true
        update_status = []
        
        Thread.new do
          last_status = $con.execute('select status_id from friends_timeline order by status_id desc limit 1').flatten
          1.upto $const.PAGE_HISTORY do |i|
            tl_a = @twitter_client.friends_timeline(i, last_status)
            p tl_a
            break if tl_a.size == 0
            update_status.concat(tl_a)
            break if tl_a.size < 20 and tl_a.size > 0
          end
          
          update_status.each do |tl|
            begin
              p "insert into friends_timeline(status_id, screen_name, created_at, text) values ('#{tl["status_id"]}', '#{tl["screen_name"]}', '#{tl["created_at"]}', \"#{tl["text"]}\")"
              $con.execute("insert into friends_timeline(status_id, screen_name, created_at, text) values ('#{tl["status_id"]}', '#{tl["screen_name"]}', '#{tl["created_at"]}', \"#{tl["text"]}\")")

              @chain.build(CGI.unescapeHTML(tl["text"]))
              @chain.learn
            rescue SQLite3::SQLException
              print "Exception:" + tl["status_id"] + " " + tl["screen_name"] + " " + tl["created_at"] + " " + tl["text"] + "\n"
            end
          end
        end
        
        sleep($const.SLEEP_TIME)
      end
    end

    def start_say
      while true
        Thread.new do 
          say = @chain.generate until say
          p say
          @twitter_client.update(say)
        end
        sleep($const.SLEEP_TIME)
      end
    end

    # TODO
    def stop
    end

    def daemon
      return yield if $DEBUG
      Process.fork {
        Process.setsid
        Dir.chdir "/"
        Signal.trap(:INT) { exit! 0 }
        Signal.trap(:TERM){ exit! 0 }
        Signal.trap(:HUP) { exit! 0 }
        File.open("/dev/null", "r+") do |f|
          STDIN.reopen f
          STDOUT.reopen f
          STDERR.reopen f
        end
        yield
      }
      exit! 0
    end
  end
end
