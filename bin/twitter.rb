#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
$KCODE='u'

cgi = CGI.new('html4')
user = cgi.params['user'][0]
pass = cgi.params['pass'][0]
comment = cgi.params['comment'][0]
if cgi.params['page'][0]
  page = cgi.params['page'][0]
else
  page = 1
end
old_page = page.to_i+1
new_page = page.to_i-1
new_page = 1 if new_page == 0
link_only = cgi.params['link'][0]

$form = "What are you doing?<br>
<form action=\"./twitter.rb\" method=\"get\">
<input type=\"hidden\" name=\"user\" value=\"#{user}\">
<input type=\"hidden\" name=\"pass\" value=\"#{pass}\">
<input type=\"text\" name=\"comment\"><br>
<input type=\"submit\" value=\"update\">
</form>"

$link = "<a href=\"./twitter.rb?user=#{user}&pass=#{pass}\">home</a>
 <a href=\"./twitter.rb?user=#{user}&pass=#{pass}&page=#{new_page}\">prev</a>
 <a href=\"./twitter.rb?user=#{user}&pass=#{pass}&page=#{old_page}\">next</a>
<hr>"

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "UTF-8"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'twitter'} } + cgi.body do
      if user and pass and comment
        Bot.update(user, pass, CGI.unescapeHTML(comment).toutf8)
      end

      html = $form + $link
      Bot.tl(page).each do |screen_name, text|
        html += "<b><font color=red>" + screen_name + "</font></b><br>" + text.toutf8 + "<br><hr>"
      end
      html += $link
      #html.gsub!(/(http)/) { "<font color=blue>#$1</font>" }
      html.gsub!(URI.regexp(['http', 'https'])) { "<a href=\"#{$&}\" target=\"_blank\">#{$&}</a>" }
      html.gsub!(/(@\w+)/) { "<font color=blue>#$1</font>" }
      CGI.unescapeHTML(html)
    end
  end
end
