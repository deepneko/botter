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
      @statetable = Hash.new
      @statetable.default = []

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
          @statetable[p_word.to_s] << { n_word => last_word }
          p @statetable[p_word.to_s]
        end
      rescue
        print "Exception: ", $!;
      end
    end

    def generate(nwords)
    end
  end

  def self.markov(data, nwords=10000)
    chain = Chain.new
    chain.build(data)
    chain.generate(nwords)
  end
end

Marcov.markov(open($*[0]).read, $*[1].to_i)

