#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
$KCODE='u'

cgi = CGI.new('html4')
cgi.unescapeHTML("&#x3042;")
keyword = cgi.params['update'][0]
page = cgi.params['page'][0]

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "Shift-JIS"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'twitter'} } + cgi.body do
      html = ""
      Bot.tl.each do |screen_name, text|
        html += "<br>" + screen_name + "<br>" + text.toutf8 + "<br><hr>"
      end
      html
    end
  end
end
