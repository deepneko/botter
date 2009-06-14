#!/usr/bin/env ruby

require 'MeCab'
require 'cgi'
$KCODE = 'u'

module Marcov
  WORD_SIZE = 3

  class Chain
    def initialize
      @words = []
      @statetable = {}
      @statetable.default = []
    end

    def build(str)
      begin
        mecab = MeCab::Tagger.new(str)
        n = mecab.parseToNode(str)
        while n do
          @words << n.surface
          n = n.next
        end

        0.upto(@words.size-2) do |i|
          j = i + 1
          p_word = @words[i]
          n_word = @words[j]
          while n_word.split(//).size < WORD_SIZE
            j = j + 1
            break if j-i > 3
            n_word += @words[j].to_s
          end
          @statetable[p_word] << n_word
        end
      rescue
        p "RuntimeError: ", $!;
      end

      p @statetable
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

