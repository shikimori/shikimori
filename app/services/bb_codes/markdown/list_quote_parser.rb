class BbCodes::Markdown::ListQuoteParser
  include Singleton

  MARKDOWN_LIST_OR_QUOTE_REGEXP = %r{
    (?: ^ | (?<prefix> #{BbCodes::BLOCK_TAG_EDGE_PREFIX_REGEXP.source} ) )
    (?:
      (?: [-+*>] | &gt; )
      \ (?:
        (?: \[(?<tag>#{BbCodes::MULTILINE_BBCODES.join('|')})[\s\S]+\[/\k<tag>\] |. )*+
        (?: \n \ + .*+ )*
      ) (?: \n|$ )
    )+
  }x
  PREFIX_REPLACEMENT = /([<\[])(\w)/

  MAX_NESTING = 3

  def format text
    bbcode_to_html(text, 1).first
  end

private

  def bbcode_to_html text, nesting = 1
    return [text, true] if nesting > MAX_NESTING

    text, were_rest_html = bbcode_to_html text, nesting + 1
    return [text, were_rest_html] unless were_rest_html

    is_rest_html = false
    text = text.gsub MARKDOWN_LIST_OR_QUOTE_REGEXP do |match|
      prefix = $LAST_MATCH_INFO[:prefix] || ''
      content_wo_prefix = match[prefix.size...]

      list_html, rest_html = parse_markdown(content_wo_prefix, prefix)
      is_rest_html = rest_html.present?

      prefix + list_html + (rest_html || '')
    end

    [text, is_rest_html]
  end

  def parse_markdown content_wo_prefix, prefix
    BbCodes::Markdown::ListQuoteParserState.new(
      content_wo_prefix,
      0,
      '',
      prefix.present? && prefix.match?(PREFIX_REPLACEMENT) ?
        prefix.gsub(PREFIX_REPLACEMENT, '\1/\2') :
        nil
    ).to_html
  end
end
