class Anidb::ProcessDescription
  def call value
    description = DbEntries::Description.from_value(value)

    text = description.text
    source = process_source(description.source, mal_url(type, id))

    DbEntries::Description.from_text_source(text, source).value
  end

  private

  def process_source source, mal_url
    if source.nil?
      mal_url
    else
      source.sub(/^ANN\z/, 'animenewsnetwork.com')
    end
  end

  def mal_url type, id
    "http://myanimelist.net/#{type}/#{id}"
  end
end
