class FindAnimeImporter
  SERVICE = :findanime

  def import pages
    parser.fetch_pages(0..0).each do |entry|
      anime_id = find_match entry

      import_episodes anime_id, entry[:episodes] if anime_id
    end
  end

private
  def import_episodes anime_id, episodes
    anime = Anime.find anime_id
    videos = episodes.map {|episode| parser.fetch_episode(episode)[:videos] }.flatten

    import_videos anime, videos
  end

  def import_videos anime, videos
    videos.each do |video|
      next if anime.anime_videos.any? {|v| v.url == video.url }

      anime.anime_videos.create!({
        episode: video.episode,
        url: video.url,
        kind: video.kind,
        language: video.language,
        source: video.source,
        anime_video_author_id: find_or_create_author(video.author).try(:id)
      })
    end
  end

  def parser
    @parser ||= FindAnimeParser.new
  end

  def matcher
    @matcher ||= NameMatcher.new Anime, nil, [:findanime]
  end

  def authors
    @authors ||= AnimeVideoAuthor.all.each_with_object({}) do |author,memo|
      memo[author.name] = author
    end
  end

  def save_link findanime_id, anime_id
    AnimeLink.create! service: SERVICE, anime_id: anime_id, identifier: findanime_id
  end

  def find_match entry
    anime_id = matcher.by_link entry[:id], SERVICE

    unless anime_id
      anime_id = matcher.get_id entry[:names]

      if anime_id
        save_link entry[:id], anime_id
      else
        puts "unmatched entry: #{entry[:id]}"
      end
    end

    anime_id
  end

  def find_or_create_author name
    return nil if name.blank?

    if authors[name]
      authors[name]
    else
      authors[name] = AnimeVideoAuthor.create! name: name
    end
  end
end
