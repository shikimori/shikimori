class BbCodes::EntryText
  method_object :text, :entry

  def call
    text = prepare @text

    text = character_names text, @entry
    text = remove_wiki_codes(text) unless @entry.is_a? Club

    BbCodes::Text.call "[div=b-text_with_paragraphs]#{text}[/div]"
  end

private

  # the same logic as in BbCodes::Text
  def prepare text
    (text || '').fix_encoding.strip.gsub(/\r\n|\r/, "\n")
  end

  def character_names text, entry
    if entry.respond_to?(:characters) && entry.respond_to?(:people)
      BbCodes::CharactersNames.call text, entry
    else
      text
    end
  end

  # must be called after character_names
  # becase [[...]] are used in BbCodes::CharactersNames
  def remove_wiki_codes text
    text
      .gsub(/\[\[[^\]|]+?\|(.*?)\]\]/, '\1')
      .gsub(/\[\[(.*?)\]\]/, '\1')
  end
end
