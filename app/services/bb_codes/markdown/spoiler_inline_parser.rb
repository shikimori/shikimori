class BbCodes::Markdown::SpoilerInlineParser
  include Singleton

  REGEXP = / \|\| (?<text> (?: (?!\|\|) .)+ ) \|\| /x

  TAG_OPEN = BbCodes::Tags::SpoilerTag::INLINE_TAG_OPEN
  TAG_CLOSE = BbCodes::Tags::SpoilerTag::INLINE_TAG_CLOSE

  def format text
    text.gsub(REGEXP) do
      text = $LAST_MATCH_INFO[:text]

      "#{TAG_OPEN}<span>#{text}</span>#{TAG_CLOSE}"
    end
  end
end
