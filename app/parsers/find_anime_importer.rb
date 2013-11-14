class FindAnimeImporter
  SERVICE = :findanime

  def initialize
    @parser = FindAnimeParser.new
    @matcher = NameMatcher.new Anime, nil, [:findanime]

    @authors = AnimeVideoAuthor.all.each_with_object({}) do |author,memo|
      memo[author.name.downcase] = author
    end

    @unmatched = []
    @ambiguous = []
    @config = YAML::load(File.open("#{::Rails.root.to_s}/config/findanime.yml"))
    @ignores = Set.new(@config[:ignores] + @config[:ignores_until].select {|k,v| v > DateTime.now }.keys)
  end

  def import pages, is_full
    @parser.fetch_pages(0..pages).each do |entry|
      next if @ignores.include?(entry[:id]) || entry[:videos].none? || entry[:categories].include?('AMV')
      anime = find_match entry

      import_videos anime, entry[:videos], is_full if anime
    end

    raise UnmatchedEntries, @unmatched.join(', ') if @unmatched.any?
    raise AmbiguousEntries, @ambiguous.join(', ') if @ambiguous.any?
  end

private
  def import_videos anime, videos, is_full
    imported_videos = anime.anime_videos.all
    last_episode = imported_videos.any? ? imported_videos.max {|v| v.episode }.episode : 0
    filtered_videos = videos.select {|episode| is_full ? true : episode[:episode] > last_episode - 3 }

    AnimeVideo.import fetch_videos(filtered_videos, anime, imported_videos)
  end

  def fetch_videos videos, anime, imported_videos
    videos
      .map {|episode| @parser.fetch_videos episode[:episode], episode[:url] }
      .flatten
      .select {|video| imported_videos.none? {|v| v.url == video[:url] && v.source == video[:source] } }
      .map {|video| build_video video, anime.id }
  end

  def build_video video, anime_id
    AnimeVideo.new({
      anime_id: anime_id,
      episode: video.episode,
      url: video.url,
      kind: video.kind,
      language: video.language,
      source: video.source,
      anime_video_author_id: find_or_create_author(video.author).try(:id)
    })
  end

  def save_link findanime_id, anime_id
    AnimeLink.create! service: SERVICE, anime_id: anime_id, identifier: findanime_id
  end

  def find_match entry
    anime = @matcher.by_link entry[:id], SERVICE

    unless anime
      animes = @matcher.matches entry[:names], year: entry[:year], episodes: entry[:episodes]

      if animes.size == 1
        anime = animes.first
        save_link entry[:id], anime.id

      elsif animes.size > 1
        @ambiguous << "#{entry[:id]} (#{animes.map(&:id).join ', '})"

      else
        @unmatched << entry[:id]
      end
    end

    anime
  end

  def find_or_create_author name
    return nil if name.blank?

    if @authors[name.downcase]
      @authors[name.downcase]
    else
      @authors[name.downcase] = AnimeVideoAuthor.create! name: name
    end
  end
end
