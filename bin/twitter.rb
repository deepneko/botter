#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
$KCODE='u'

cgi = CGI.new('html4')
comment = cgi.params['comment'][0]
page = cgi.params['page'][0]
link_only = cgi.params['link'][0]

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "Shift-JIS"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'twitter'} } + cgi.body do
      html = $form
      Bot.tl.each do |screen_name, text|
        html += "<b><font color=red>" + screen_name + "</font></b><br>" + text.toutf8 + "<br><hr>"
      end
      html.gsub!(/(http)/) { "<font color=blue>#$1</font>" }
      html.gsub!(/(@\w+)/) { "<font color=blue>#$1</font>" }
      CGI.unescapeHTML(html)
    end
  end
end
