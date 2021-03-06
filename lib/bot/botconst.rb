module Bot
  class BotConst
    attr_accessor :TWITTER_FRIENDS_TIMELINE
    attr_accessor :TWITTER_UPDATE
    attr_accessor :PAGE_HISTORY
    attr_accessor :SLEEP_TIME
    attr_accessor :DB
    attr_accessor :MARCOV_WORD_SIZE
    attr_accessor :MARCOV_WORD_NUM
    attr_accessor :NOUN

    def initialize
      @TWITTER_FRIENDS_TIMELINE = "http://twitter.com/statuses/friends_timeline.xml"
      @TWITTER_UPDATE = "http://twitter.com/statuses/update.xml"

      # need configuration
      @PAGE_HISTORY = 5
      @SLEEP_TIME = 300
      @DB = "bot.db"

      # marcov configuration
      @MARCOV_WORD_SIZE = 3
      @MARCOV_WORD_NUM = 3
      @NOUN = "名詞"
    end
  end
end
