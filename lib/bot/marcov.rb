#!/usr/bin/env ruby

require 'MeCab'
require 'cgi'
$KCODE = 'u'

module Marcov
  WORD_SIZE = 4
  WORD_NUM = 3

  class Chain
    def initialize
      @words = []
      @statetable = {}
      @statetable.default = []
      @ignore = ["\n", "/", "\"", "'", "`", "^", ".", ",", "[", "]", "「", "」", "(", ")", "｢", "｣", "{", "}"]
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
          n_word = @words[j]
          while n_word.split(//).size < WORD_SIZE
            j = j + 1
            break if j-i > WORD_NUM
            n_word += @words[j].to_s
          end
          @statetable[p_word] << n_word
        end

        p @words
        p @statetable
      rescue
        print "Exception: ", $!;
      end
    end

    def ignore
      return false if @ignore.
      return false if @word ~= /^[-.0-9]$/
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

