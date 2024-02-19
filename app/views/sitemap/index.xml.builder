cache :sitemap, expires_in: 1.day do
  xml.instruct!
  xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
    xml.url do
      xml.loc root_url(only_path: false)
      # xml.lastmod entry.updated_at.to_date
      xml.tag! 'changefreq', 'hourly'
      xml.tag! 'priority', '1'
    end
    @forums.each do |_title, url|
      xml.url do
        xml.loc url
        xml.tag! 'changefreq', 'daily'
        xml.tag! 'priority', '0.20'
      end
    end
    [
      @anime_seasons,
      @anime_genres_demographic,
      @anime_genres_genre,
      @anime_genres_theme
    ].each do |group|
      group.each do |_title, url|
        xml.url do
          xml.loc url
          xml.tag! 'changefreq', 'weekly'
          xml.tag! 'priority', '0.70'
        end
      end
    end
    @anime_misc_genres.each do |_title, url|
      xml.url do
        xml.loc url
        xml.tag! 'changefreq', 'weekly'
        xml.tag! 'priority', '0.60'
      end
    end
    @manga_seasons.each do |_title, url|
      xml.url do
        xml.loc url
        xml.tag! 'changefreq', 'weekly'
        xml.tag! 'priority', '0.70'
      end
    end
    @ranobe_forums.each do |_title, url|
      xml.url do
        xml.loc url
        xml.tag! 'changefreq', 'weekly'
        xml.tag! 'priority', '0.70'
      end
    end

    @animes.each do |entry|
      xml.url do
        xml.loc anime_url(entry)
        # xml.lastmod [@last_animepage_change, entry.updated_at].max.to_date
        xml.tag! 'changefreq', 'weekly'
        xml.tag! 'priority', '0.4'
      end
    end
    @mangas.each do |entry|
      xml.url do
        xml.loc manga_url(entry)
        # xml.lastmod [@last_animepage_change, entry.updated_at].max.to_date
        xml.tag! 'changefreq', 'weekly'
        xml.tag! 'priority', '0.4'
      end
    end
  end
end
