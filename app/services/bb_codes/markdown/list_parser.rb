class BbCodes::Markdown::ListParser
  include Singleton
  MARKDOWN_LIST_REGEXP = /
    ^[-+*]\ (?<content> .*+ (?:\n\ \ .*+)*) (?:\n|$)
  /x
  MARKDOWN_LISTS_REGEXP = /
    (?: #{MARKDOWN_LIST_REGEXP.source} )+
  /x

  UL_START = "<ul class='b-list'>"
  UL_END = '</ul>'

  def format text
    format_markdown_lists text
  end

private

  def format_markdown_lists text
    text.gsub MARKDOWN_LISTS_REGEXP do |match|
      UL_START + format_markdown_items(match) + UL_END
    end
  end

  def format_markdown_items text
    text.gsub(MARKDOWN_LIST_REGEXP) do
      "<li>#{$LAST_MATCH_INFO[:content]}</li>"
    end
  end
end
