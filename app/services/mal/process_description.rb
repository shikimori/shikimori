class Mal::ProcessDescription
  method_object :value, :type, :id

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
      mal_url
    else
      source.sub(/^ANN\z/, 'animenewsnetwork.com')
    end
  end

  def mal_url
    "http://myanimelist.net/#{type}/#{id}"
  end
end
