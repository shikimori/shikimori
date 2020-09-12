class BbCodes::Markdown::ListQuoteParser
  include Singleton

  MARKDOWN_LIST_OR_QUOTE_REGEXP = %r{
    (?:
      (?: ^ | (?<prefix> #{BbCodes::BLOCK_TAG_EDGE_PREFIX_REGEXP.source} ) )
      (?: [-+*>] | &gt; )
      \ (?:
        (?: \[(?<tag>#{BbCodes::MULTILINE_BBCODES.join('|')})[\s\S]+\[/\k<tag>\] |. )*+
        (?: \n \ + .*+ )*
      ) (?: \n|$ )
    )+
  }x

  def format text
    text.gsub MARKDOWN_LIST_OR_QUOTE_REGEXP do |match|
      prefix = $LAST_MATCH_INFO[:prefix] || ''

      prefix + BbCodes::Markdown::ListQuoteParserState.new(match).to_html
    end
  end
end
