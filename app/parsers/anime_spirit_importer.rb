class AnimeSpiritImporter < FindAnimeImporter
  SERVICE = 'animespirit'

  def fetch_videos videos, anime, imported_videos
    videos
      .select {|video| imported_videos.none? {|v| v.url == video[:url] && v.source == video[:source] } }
      .map {|video| build_video video, anime.id }
      .compact
  end
end
