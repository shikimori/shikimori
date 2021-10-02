class Anidb::ProcessDescription
  method_object :value, :anidb_url

  def call
    description = DbEntries::Description.from_value(value)

    text = description.text
    return if text.blank?

    source = process_source(description.source)

    DbEntries::Description.from_text_source(text, source).value
  end

  private

  def process_source source
    if source.nil?
      anidb_url
    else
      source.sub(/^ANN\z/, 'animenewsnetwork.com')
    end
  end
end
