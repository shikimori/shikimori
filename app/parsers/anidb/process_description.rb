class Anidb::ProcessDescription < ServiceObjectBase2
  def call value, anidb_url
    description = DbEntries::Description.from_value(value)

    text = description.text
    source = process_source(description.source, anidb_url)

    DbEntries::Description.from_text_source(text, source).value
  end

  private

  def process_source source, anidb_url
    if source.nil?
      anidb_url
    else
      source.sub(/^ANN\z/, 'animenewsnetwork.com')
    end
  end
end
