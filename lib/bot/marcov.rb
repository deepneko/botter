#!/usr/bin/env ruby

require 'MeCab'
require 'cgi'
$KCODE = 'u'

module Marcov
  NPREF = 2
  NONWORD = "\n"

  class Chain
    def initialize
      @statetable = {}
      @statetable.default = []
      @prefix = []
    end

    def build(str)
      begin
        c = MeCab::Tagger.new(str)
        p c.parse(str)
        n = c.parseToNode(str)
        while n do
          add(n.surface)
          #print n.surface,  "\t", n.feature, "\t", n.cost, "\n"
          n = n.next
        end
      rescue
        p "RuntimeError: ", $!;
      end
      add(NONWORD)
    end

    def add(word)
      suf = @statetable[@prefix]
      if !suf
        suf = []
        pref = Array.new(NPREF){NONWORD}
        @statetable[pref] = suf
      end

      suf << word
      @prefix.shift
      @prefix << word
    end

    def generate(nwords)
      @prefix = Array.new(NPREF){NONWORD}
      nwords.times do
        s = @statetable[@prefix]
        r = rand(31) % s.size
        suf = s[r]
        break if suf == NONWORD
        print CGI.unescapeHTML(suf)
        @prefix.shift
        @prefix << suf
      end
    end
  end

  def self.markov(data, nwords=10000)
    chain = Chain.new
    chain.build(data)
    chain.generate(nwords)
  end
end

Marcov.markov(open($*[0]).read, $*[1].to_i)


