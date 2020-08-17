class BbCodes::Tags::SpoilerTag
  include Singleton

  REGEXP = %r{
    \[spoiler (?:= (?<label> [^\[\]\n\r]+? ) )? \]
      \n?
      (?<content>
        (?:
          (?! \[/?spoiler\] ) (?>[\s\S])
        )+
      )
      \n?
    \[/spoiler\]
  }xi

  def format text
    spoiler_to_html text, 0
  end

private

  def spoiler_to_html text, nesting
    return text if nesting > 10

    text = spoiler_to_html text, nesting + 1

    text.gsub(REGEXP) do |_match|
      <<~HTML.squish
        <div class='b-spoiler
          unprocessed'><label>#{$LAST_MATCH_INFO[:label] || I18n.t('markers.spoiler')}</label><div
          class='content'><div class='before'></div><div
          class='inner'>#{$LAST_MATCH_INFO[:content]}</div><div
          class='after'></div></div></div>
      HTML
    end
  end
end
