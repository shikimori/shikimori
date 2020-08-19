class BbCodes::Markdown::ListQuoteParser
  include Singleton

  MARKDOWN_LIST_OR_QUOTE_REGEXP = /
    (
      (?: ^ | (?<=<<-CODE-\d-PLACEHODLER->>) )
      ([-+*>]|&gt;)
      \ (?:
        (?: . )*+
        (?:\n \ + .*+ )*
      ) (?:\n|$)
    )+
  /x

  def format text
    text.gsub MARKDOWN_LIST_OR_QUOTE_REGEXP do |match|
      BbCodes::Markdown::ListQuoteParserState.new(match).to_html
    end
  end
end
