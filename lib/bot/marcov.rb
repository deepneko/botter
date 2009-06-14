#!/usr/bin/env ruby

require 'MeCab'
require 'cgi'
$KCODE = 'u'

module Marcov
  NSIZE = 3

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
          @words << n
          n = n.next
        end

        @words.size.times do |i|
          p_word = n_word = @words[i]
          j = i
          while p_word.split(//) > NSIZE
            j = j + 1
            n_word += @words[j] if j < @words.size
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

