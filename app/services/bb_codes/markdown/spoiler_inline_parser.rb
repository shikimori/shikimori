class BbCodes::Markdown::SpoilerInlineParser
  include Singleton

  REGEXP = / \|\| (?<text> (?: (?!\|\|) .)+ ) \|\| /x

  def format text
    text.gsub(REGEXP) do
      text = $LAST_MATCH_INFO[:text]

      "<button class='b-spoiler_inline to-process' data-dynamic='spoiler_inline'>" \
        "<span>#{text}</span>" \
      '</button>'
    end
  end
end
