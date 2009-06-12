#!/usr/bin/env ruby

require 'MeCab'

module Marcov
  class Prefix
    attr_reader :pref
    MULTIPLIER = 31

    def initialize(p)
      @pref = p
    end

    def initialize(n, str)
      @pref = []
      n.times do
        @pref << str
      end
    end

    def hashcode
      h = 0
      @pref.each do |p|
        h = MULTIPLIER * h + p.hashcode
      end
    end

    def equals(p)
      @pref.size.times do |i|
        return false if !@pref[i].equals(p.pref[i])
      end
      return true
    end
  end

  class Chain
    NPREF = 2
    NONWORD = "\n"

    def initialize
      @statetable = {}
      @prefix = Prefix.new(NPREF, NONWORD)
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
    end

    def add(word)
      suf = @statetab[prefix]
      if !suf
        suf = []
        @statetable[Prefix.new(prefix)] = suf
      end

      suf << word
      prefix.pref.shift
      prefix.pref << word
    end

    def generate(nwords)
      prefix = Prefix.new(NPREF, NONWORD)
      nwords.times do
        s = @statetable[prefix]
        r = rand % s.size
        p r
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
