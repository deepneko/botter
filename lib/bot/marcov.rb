#!/usr/bin/env ruby

require 'MeCab'
require 'cgi'
$KCODE = 'u'

module Marcov
  WORD_SIZE = 3
  WORD_NUM = 3

  class Chain
    def initialize
      @words = []
      @statetable = Hash.new { [] }

      @ignore = ["", "\n", "/", "\"", "'", "`", "^", ".", ",", "[", "]", "「", "」", "(", ")", "｢", "｣", "{", "}", "（", "）", "【", "】", "<", ">", "‘", "’", "『", "』", "“", "”", "〔", "〕",]
      @end = ["。", " ", "　", "!", "！", "?", "？"]
    end

    def build(str)
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
          while n_word.split(//).size < WORD_SIZE
            j = j + 1
            break if j-i > WORD_NUM
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

    def generate(nwords)
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

  def self.markov(data, nwords=10000)
    chain = Chain.new
    chain.build(data)
    chain.generate(nwords)
  end
end

Marcov.markov(open($*[0]).read, $*[1].to_i)

