module Bot
  class TwitterAPI
    def initialize(user, pass)
      @const = BotConst.new
      @user = user
      @pass = pass
    end

    def login(user, pass)
      agent = WWW::Mechanize.new
      agent.auth(user, pass)
      agent
    end

    def friends_timeline(page=1, since_id=[])
      # for mechanize bug
      @agent = login(@user, @pass)

      url = @const.TWITTER_FRIENDS_TIMELINE + "?page=#{page}"
      url += "&since_id=#{since_id[0]}" if since_id.size > 0
      p url
      res = @agent.get(url)

      ft_a = []
      doc = Hpricot(res.body)
      (doc/:status).each do |status|
        ft_h = {}
        ft_h['status_id'] = (status/:id).inner_html.gsub((status/:user/:id).inner_html, "")
        ft_h['screen_name'] = (status/:user/:screen_name).inner_html
        ft_h['created_at'] = (status/:created_at).inner_html
        ft_h['text'] = (status/:text).inner_html
        ft_a << ft_h
      end
      ft_a
    end

    def update(text)
      # for mechanize bug
      @agent = login(@user, @pass)

      res = @agent.post(@const.TWITTER_UPDATE, { 'status' => text })
      ret = nil
      if res.code == '200'
        doc = Hpricot(res.body)
        (doc/:status).each do |status|
          ret = (status/:created_at).inner_html
        end
      end
      ret
    end
  end
end
