#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
$KCODE='u'
#CGI.unescapeHTML("&#x3042;")

cgi = CGI.new('html4')
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
        html += "<br><b><font color=red>" + screen_name + "</font></b><br>" + text.toutf8 + "<br><hr>"
      end
      html.gsub(/(@.+\s+)/, "<font color=blue>#$1</font>")
      CGI.unescapeHTML(html)
    end
  end
end
