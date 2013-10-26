class AnimedbRuScreenshotsJob
  def perform
    parser = AnimedbRuParser.new
    ids = parser.fetch_ids_with_screenshots
    return if ids.empty?
    raise 'ids found! is animedb not dead!?' if ids.any?
    print "found ids: %s\n" % ids.join(',')
    parser.update_animes(ids)
    parser.merge_russian(ids)
    parser.merge_screenshots
  end
end
