class FindAnimeImporter
  SERVICE = 'findanime'

  def initialize
    @parser = self.class.name.sub(/Importer$/, 'Parser').constantize.new
    @matcher = NameMatcher.new Anime, nil, [service.to_sym]

    @authors = AnimeVideoAuthor.all.each_with_object({}) do |author,memo|
      memo[author.name.downcase] = author
    end

    @unmatched = []
    @ambiguous = []
    @twice_matched = []
    @config = YAML::load(File.open("#{::Rails.root.to_s}/config/#{service}.yml"))
    @ignores = Set.new(@config[:ignores] + @config[:ignores_until].select {|k,v| v > DateTime.now }.keys)
  end

  def import ids: [], pages: [], last_episodes: false
    fetch_pages(pages).each {|(id, anime, videos)| import_videos anime, videos, last_episodes } if pages.any?
    fetch_ids(ids).each {|(id, anime, videos)| import_videos anime, videos, last_episodes } if ids.any?

    raise MismatchedEntries.new @unmatched, @ambiguous, @twice_matched if @unmatched.any? || @ambiguous.any? || @twice_matched.any?
  end

private
  def service
    self.class::SERVICE
  end

  def import_videos anime, videos, last_episodes
    imported_videos = anime.anime_videos.to_a
    last_episode = imported_videos.select(&:allowed?).any? ? imported_videos.select(&:allowed?).max {|v| v.episode }.episode : 0
    filtered_videos = videos.select {|episode| last_episodes ? episode[:episode] > last_episode - 3 : true }

    #AnimeVideo.import fetch_videos(filtered_videos, anime, imported_videos)
    fetch_videos(filtered_videos, anime, imported_videos).each &:save!
  end

  def fetch_videos videos, anime, imported_videos
    videos
      .map {|episode| @parser.fetch_videos episode[:episode], episode[:url] }
      .flatten
      .select {|video| imported_videos.none? {|v| v.url == video[:url] && v.source == video[:source] } }
      .map {|video| build_video video, anime.id }
      .compact
  end

  def fetch_ids ids
    process_parsed ids.map {|id| @parser.fetch_entry id }
  end

  def fetch_pages pages
    process_parsed @parser.fetch_pages(pages)
  end

  def process_parsed entries
    data = entries.map do |entry|
      next if @ignores.include?(entry[:id]) || entry[:videos].none? || entry[:categories].include?('AMV')
      [entry[:id], find_match(entry), entry[:videos]]
    end

    filter_data data
  end

  def filter_data data
    data.delete_if {|(id, anime, videos)| anime.nil? }
    data
      .group_by {|(id, anime, videos)| anime.id }
      .select {|anime_id, entries| entries.uniq {|v| v.first }.size > 1 }
      .each do |anime_id, entries|
        entries.each {|v| data.delete v }
        @twice_matched << "#{anime_id} (#{entries.map {|(id, anime, videos)| id }.join ', '})"
        AnimeLink.where(
          service: service,
          anime_id: anime_id,
          identifier: entries.map {|(id, anime, videos)| id }
        ).delete_all
      end

    data
  end

  def build_video video, anime_id
    AnimeVideo.new(
      anime_id: anime_id,
      episode: video.episode,
      url: video.url,
      kind: video.kind,
      language: video.language,
      source: video.source,
      anime_video_author_id: find_or_create_author(video.author).try(:id),
      state: 'working'
    )
  end

  def save_link findanime_id, anime_id
    AnimeLink.create! service: service, anime_id: anime_id, identifier: findanime_id
  end

  def find_match entry
    anime = @matcher.by_link entry[:id], service.to_sym

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
