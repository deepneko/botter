#!/usr/bin/env ruby

require 'MeCab'

module Marcov
  NPREF = 2
  NONWORD = "\n"
  MULTIPLIER = 31

  class Prefix
    attr_accessor :pref

    def initialize(n=NPREF, str=NONWORD)
        @pref = Array.new(n){str}
    end

    def copy(p)
      @pref = p.pref.clone
    end

    def hashcode
      h = 0
      @pref.each do |p|
        h = MULTIPLIER * h + p.hashcode
      end
      h
    end

    def equals(p)
      @pref.size.times do |i|
        return false if !@pref[i].equals(p.pref[i])
      end
      return true
    end
  end

  class Chain
    def initialize
      @statetable = {}
      @statetable.default = []
      @prefix = Prefix.new
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
      suf = @statetable[@prefix.pref]
      if !suf
        suf = []
        p = Prefix.new
        @statetable[p.pref] = suf
      end

      suf << word
      @prefix.pref.shift
      @prefix.pref << word
    end

    def generate(nwords)
      prefix = Prefix.new
      nwords.times do
        s = @statetable[prefix.pref]
        r = rand % s.size
        suf = s[r]
        break if suf == NONWORD
        p suf
        prefix.pref.shift
        prefix.pref << suf
      end
    end
  end

  def self.markov(data, nwords=10000)
    chain = Chain.new
    chain.build(data)
    chain.generate(nwords)
  end
end

Marcov.markov(open($*[0]).read)


