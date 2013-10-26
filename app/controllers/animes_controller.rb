require 'rss'

class AnimesController < AniMangasController
  # rss лента новых серий и сабов аниме
  def rss
    anime = Anime.find(params[:id].to_i)

    case params[:type]
      when 'torrents'
        data = anime.torrents
        title = 'Торренты %s' % anime.name

      when 'torrents_480p'
        data = anime.torrents_480p
        title = 'Серии 480p %s' % anime.name

      when 'torrents_720p'
        data = anime.torrents_720p
        title = 'Серии 720p %s' % anime.name

      when 'torrents_1080p'
        data = anime.torrents_1080p
        title = 'Серии 1080p %s' % anime.name

      when 'subtitles'
        if anime.subtitles.include? params[:group]
          data = anime.subtitles[params[:group]][:feed].reverse
        else
          data = []
        end
        title = 'Субтитры %s' % anime.name
    end

    feed = RSS::Maker.make("2.0") do |feed|
      feed.channel.title = title
      feed.channel.link = request.url
      feed.channel.description = "%s, найденные сайтом." % title
      feed.items.do_sort = true # sort items by date

      data.reverse.each do |item|
        entry = feed.items.new_item

        entry.title = item[:title].html_safe
        entry.link = item[:link].html_safe
        entry.description = "Seeders: %d, Leechers: %d" % [item[:seed], item[:leech]] if item[:seed] || item[:leech]
        entry.date = item[:pubDate] != nil ? Time.at(item[:pubDate].to_i) : Time.now
      end
    end

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render :text => feed
  end
end
