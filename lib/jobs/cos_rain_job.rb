class CosRainJob
  def perform
    Proxy.use_cache = true
    Proxy.show_log = true

    parser = CosRainParser.new
    parser.fetch_links
    parser.fetch_entries
    parser.merge_with_database

    Proxy.use_cache = false
    Proxy.show_log = false
  end
end
