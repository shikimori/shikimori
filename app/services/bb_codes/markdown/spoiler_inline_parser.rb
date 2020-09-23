class BbCodes::Markdown::SpoilerInlineParser
  include Singleton

  REGEXP = / \|\| (?<text> (?: (?!\|\|) .)+ ) \|\| /x

  TAG_OPEN = BbCodes::Tags::SpoilerTag::INLINE_TAG_OPEN
  TAG_CLOSE = BbCodes::Tags::SpoilerTag::INLINE_TAG_CLOSE

  FORBIDDEN_BBCODES = BbCodes::MULTILINE_BBCODES - %w[spoiler_v1] + %w[poll]
  FORBIDDEN_BBCODES_REGEXP = /\[(?:#{FORBIDDEN_BBCODES.join '|'}|\*)(?:\b|\])/

  def format text
    text.gsub(REGEXP) do |match|
      text = $LAST_MATCH_INFO[:text]

      if !text.match? FORBIDDEN_BBCODES_REGEXP
        "#{TAG_OPEN}<span>#{text}</span>#{TAG_CLOSE}"
      else
        match
      end
    end
  end
end
