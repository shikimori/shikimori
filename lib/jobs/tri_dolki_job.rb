class TriDolkiJob
  def perform
    parser = TriDolkiParser.new
    parser.fetch_links
    parser.fetch_entries
    parser.merge_with_database
  end
end
