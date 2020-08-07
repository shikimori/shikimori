class BbCodes::Markdown::ListParser
  include Singleton

  MARKDOWN_LISTS_REGEXP = /
    (
      ^[-+*]\ (?: .*+ (?:\n\ +.*+)*) (?:\n|$)
    )+
  /x

  UL_START = "<ul class='b-list'>"
  UL_END = '</ul>'

  def format text
    text.gsub MARKDOWN_LISTS_REGEXP do |match|
      BbCodes::Markdown::ListParserState.new(match).to_html
    end
  end
end
