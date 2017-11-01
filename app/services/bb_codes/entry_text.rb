class BbCodes::EntryText
  method_object :text, :entry

  def call
    BbCodes::Text.call(
      paragraphs(remove_wiki_codes(character_names(fix(@text), @entry)))
    )
  end

private

  def character_names text, entry
    if entry.respond_to?(:characters) && entry.respond_to?(:people)
      BbCodes::CharactersNames.call text, entry
    else
      text
    end
  end

  def paragraphs text
    BbCodes::Paragraphs.call text
  end

  def fix text
    text || ''
  end

  # must be called after character_names
  # becase [[...]] are used in BbCodes::CharactersNames
  def remove_wiki_codes text
    text
      .gsub(/\[\[[^\]|]+?\|(.*?)\]\]/, '\1')
      .gsub(/\[\[(.*?)\]\]/, '\1')
  end
end
