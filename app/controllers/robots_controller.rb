class RobotsController < ApplicationController
  def animeonline
    render content_type: 'text/plain', text: <<-EOS
User-agent: *
Disallow: /
EOS
  end

  def shikimori
    render content_type: 'text/plain', text: <<-EOS
User-agent: *
Disallow: /*?
Disallow: /*?rel=nofollow
Disallow: /cosplay/*
Disallow: /animes/*rss
Disallow: /animes/order-by/*
Disallow: /mangas/*rss
Disallow: /mangas/order-by/*
Disallow: /*/stats
Disallow: /*/message
Disallow: /*/settings
Disallow: /*/comments
Disallow: /*/menu
Disallow: /*/tooltip
Disallow: /*/talk
Disallow: /groups/9-Hentai*
Disallow: /messages/*
Disallow: /*undefined
Disallow: /api/*
Disallow: /*.html
Host: shikimori.org
Sitemap: http://shikimori.org/sitemap.xml

User-agent: AhrefsBot
User-agent: moget
User-agent: ichiro
User-agent: NaverBot
User-agent: Yeti
User-agent: Baiduspider
User-agent: Baiduspider-video
User-agent: Baiduspider-image
User-agent: sogou spider
User-agent: YoudaoBot
User-agent: Yahoo Pipes 1.0
User-agent: Yahoo Pipes 2.0
Disallow: /
EOS
  end
end
