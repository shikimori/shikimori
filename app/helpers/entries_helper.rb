module EntriesHelper
  def build_news_url(entry)
    news_url(entry, :year => entry.year, :month => entry.month, :day => entry.day)
  end
end
