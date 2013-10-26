class AniDbJob < JobWithRestart
  def do
    parser = AniDbParser.new
    parser.fetch_and_apply_animes_dump
    parser.fetch_animes(true)
    parser.merge_animes_with_database
    #parser.fetch_studios(true)
    #parser.merge_studios_with_database
  end
end
