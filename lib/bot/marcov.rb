module Bot
  class Chain
    def initialize
      @words = []
      @statetable = Hash.new{[]}

      @ignore = ["", "\n", "/", "\"", "'", "`", "^", ".", ",", "[", "]", "「", "」", "(", ")", "｢", "｣", "{", "}", "（", "）", "【", "】", "<", ">", "‘", "’", "『", "』", "“", "”", "〔", "〕",]
      @end = ["。", " ", "　", "!", "！", "?", "？"]
    end

    def build(str)
      str.gsub!(URI.regexp(['http', 'https'])) { "" }
      str.gsub!(/(@\w+)/) { "" }
      str.gsub!(/RT\s+@\w+:/) { "" }

      @words = []
      @statetable = Hash.new{[]}

      begin
        mecab = MeCab::Tagger.new(str)
        n = mecab.parseToNode(str)
        while n do
          word = n.surface.strip
          @words << word unless @ignore.include?(word)
          n = n.next
        end

        0.upto(@words.size-2) do |i|
          j = i + 1
          p_word = @words[i]
          n_word = last_word = @words[j]
          while n_word.split(//).size < $const.MARCOV_WORD_SIZE
            j = j + 1
            break if j-i > $const.MARCOV_WORD_NUM
            last_word = @words[j].to_s
            n_word += last_word
          end
          a = @statetable[p_word]
          a << [n_word, last_word]
          @statetable[p_word] = a
        end
      rescue
        print "Exception: ", $!;
      end
    end

    def learn
      @statetable.keys.each do |p_word|
        @statetable[p_word].each do |n_word, last_word|
          begin
            cur = $con.execute("select * from learn_ngram where word='#{p_word}' and next='#{n_word}'").flatten
            if cur.size == 0
              p "insert p_word:" + p_word + " n_word:" + n_word + " last_word:" + last_word
              $con.execute("insert into learn_ngram (word, next, last, score) values ('#{p_word}', '#{n_word}', '#{last_word}', '1')")
            else
              p "update p_word:" + p_word + " n_word:" + n_word + " last_word:" + last_word
              $con.execute("update learn_ngram set score='#{cur[3].to_i+1}' where word='#{p_word}' and next='#{n_word}'")
            end
          rescue SQLite3::SQLException
            p "Exception p_word:" + p_word + " n_word:" + n_word + " last_word:" + last_word
          end
        end
      end
    end
    
    def generate(nwords)
      update = ""
      num_row = $con.execute("select count(*) from learn_ngram").flatten.first

      feature = nil
      while feature != $const.NOUN do
        cur = $con.execute("select * from learn_ngram where rowid=#{rand(num_row)}").flatten
        prev_word = cur[0]
        mecab = MeCab::Tagger.new(prev_word)
        n = mecab.parse(prev_word)
        feature = n.split(/\t/)[1].split(/,/)[0]
      end

      update += prev_word
      while !@end.include?(prev_word) do
        cur = $con.execute("select * from learn_ngram where word='#{prev_word}'")
        choice = cur.dup
        cur.size.times do |i|
          (cur[i][3].to_i - 1).times do 
            choice << cur[i]
          end
        end
        random = rand(cur.size)
        p cur
        update += cur[random][1]
        prev_word = cur[random][2]
      end

      p update
    end

    def generate_test(nwords)
      prevs = @statetable.keys
      p_word = prevs[rand(prevs.size)]
      p p_word
      loop do
        nexts = @statetable[p_word]
        rand = rand(nexts.size)
        n_word = nexts[rand][0]
        p n_word
        break if @end.include?(n_word)
        p_word = nexts[rand][1]
      end
      print "\n"
    end
  end

  def self.learn(data)
    chain = Chain.new
    chain.build(data)
    chain.learn
  end

  def self.test(data, nwords=10000)
    chain = Chain.new
    chain.build(data)
    chain.generate_test(nwords)
  end
end

#Bot.test(open($*[0]).read, $*[1].to_i)

