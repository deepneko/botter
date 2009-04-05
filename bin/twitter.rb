#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'bot'
$KCODE='u'

cgi = CGI.new('html4')
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

$form = <<"FORM"
What are you doing?<br>
<form action="./twitter.cgi" method="get">
<input type="text" name="comment"><br>
<input type="submit" value="update">
</form>
FORM

$link = <<"LINK"
<a href=\"./twitter.rb\">home</a>
 <a href=\"./twitter.rb?page=#{new_page}\">prev</a>
 <a href=\"./twitter.rb?page=#{old_page}\">next</a>
<hr>
LINK

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "Shift-JIS"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'twitter'} } + cgi.body do
      if comment
        Bot.update(comment)
      end

      html = $form + $link
      Bot.tl(page).each do |screen_name, text|
        html += "<b><font color=red>" + screen_name + "</font></b><br>" + text.toutf8 + "<br><hr>"
      end
      html += $link
      html.gsub!(/(http)/) { "<font color=blue>#$1</font>" }
      html.gsub!(/(@\w+)/) { "<font color=blue>#$1</font>" }
      CGI.unescapeHTML(html)
    end
  end
end
