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
      content_wo_prefix = match[prefix.size...]

      list_html = BbCodes::Markdown::ListQuoteParserState.new(
        content_wo_prefix,
        0,
        '',
        prefix.present? && prefix[1] != '/' && prefix[1] != '<' ?
          prefix.gsub('<', '</') :
          nil
      ).to_html

      prefix + list_html
    end
  end
end
