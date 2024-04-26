class RobotsController < ShikimoriController
  skip_before_action :force_301_redirect_for_guests
  skip_before_action :force_seo_redirect

  def shikimori # rubocop:disable all
    render plain: <<~ROBOTS
      User-agent: *
      Disallow: /*?
      Disallow: /*?rel=nofollow
      Disallow: /cosplay/*
      Disallow: /genres
      Disallow: /animes/*rss
      Disallow: /animes/order-by/*
      Disallow: /mangas/*rss
      Disallow: /mangas/order-by/*
      Disallow: /animes/search/*
      Disallow: /mangas/search/*
      Disallow: /*/comments
      Disallow: /*/tooltip
      Disallow: /*/autocomplete
      Disallow: /*/autocomplete/v2
      Disallow: /groups/9-Hentai*
      Disallow: /messages/*
      Disallow: /*undefined
      Disallow: /api/*
      Disallow: /*.html
      Disallow: /*/*.rss
      Disallow: /clubs/3*
      Host: #{Shikimori::PROTOCOLS[:production]}://#{Shikimori::DOMAINS[:production]}
      Sitemap: #{Shikimori::PROTOCOLS[:production]}://#{Shikimori::DOMAINS[:production]}/sitemap.xml

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
    ROBOTS
  end
end
