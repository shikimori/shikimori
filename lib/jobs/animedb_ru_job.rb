class AnimedbRuJob < JobWithRestart
  def do
    parser = AnimedbRuParser.new
    parser.cache[:max_id] = parser.fetch_max_id
    parser.fetch_animes(false, 1)
    parser.merge_russian
    parser.merge_screenshots
  end
end
