class BbCodes::Markdown::ListQuoteParser
  include Singleton

  MULTILINE_BBCODES = %w[spoiler spoiler_block quote div center right list]

  MARKDOWN_LIST_OR_QUOTE_REGEXP = %r{
    (?:
      (?: ^ | (?<=<<-CODE-\d-PLACEHODLER->> | </div> | </h\d>) )
      (?: [-+*>] | &gt; )
      \ (?:
        (?: \[(?<tag>#{MULTILINE_BBCODES.join('|')})[\s\S]+\[/\k<tag>\] |. )*+
        (?: \n \ + .*+ )*
      ) (?: \n|$ )
    )+
  }x

  def format text
    text.gsub MARKDOWN_LIST_OR_QUOTE_REGEXP do |match|
      BbCodes::Markdown::ListQuoteParserState.new(match).to_html
    end
  end
end
