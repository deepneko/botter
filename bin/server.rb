#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
require 'optparse'

# create table if db doesn't exist
Bot.createtable

# parse option
getopt = Hash.new
begin
  OptionParser.new do |opt|
    opt.on('-u VALUE') {|v| getopt[:u] = v }
    opt.on('-p VALUE') {|v| getopt[:p] = v }
    opt.on('-s VALUE') {|v| getopt[:s] = v }
    opt.parse!(ARGV)
  end
rescue
  p "usage: ./server.rb -u [user name] -p [password]"
  p "usage: ./server.rb -u [user name] -p [password] -s [any]"
  exit! 0
end

# start server
if getopt[:s]
  Bot.start(getopt[:u], getopt[:p], 30, getopt[:s])
else
  Bot.start(getopt[:u], getopt[:p], 30)
end

