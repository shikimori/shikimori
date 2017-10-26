class BbCodes::Description
  method_object :text, :entry

  def call
    BbCode.instance.format_comment(
      paragraphs(character_names(fix(@text), @entry))
    )
  end

private

  def character_names text, entry
    if entry.respond_to? :characters
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
end
