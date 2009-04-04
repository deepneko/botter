#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'

cgi = CGI.new('html4')
keyword = cgi.params['update'][0]
page = cgi.params['page'][0]

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "Shift-JIS"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'twitter'} } + cgi.body do
      html = "<html><head><meta http-equiv=\"Content-type\" content=\"text/html; charset=Shift-JIS\" /><title>twitter</title></head><body>"
      Bot.tl.each do |screen_name, text|
        html += "<br>" + screen_name + "<br>" + text + "<br><hr>"
      end
      html += "</body></html>"
      html
    end
  end
end
