class WorldArtJob < JobWithRestart
  def do
    parser = WorldArtParser.new
    parser.cache[:max_id] = parser.fetch_max_id
    parser.fetch_animes(true)
    parser.merge_with_database
  end
end
