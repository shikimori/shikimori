class BbCodes::Markdown::SpoilerInlineParser
  include Singleton

  REGEXP = / \|\| (?<text> .* ) \|\| /x

  def format text
    text.gsub(REGEXP) do
      text = $LAST_MATCH_INFO[:text]

      <<~HTML.squish
        <span class='b-spoiler_inline' to-process'
          data-dynamic='spoiler_inline'><span>#{text}</span></span>
      HTML
    end
  end
end
