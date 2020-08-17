class BbCodes::Tags::SpoilerTag
  include Singleton

  REGEXP = %r{
    (?<is_outer_n>^)?
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
      label = $LAST_MATCH_INFO[:label] || I18n.t('markers.spoiler')
      content = $LAST_MATCH_INFO[:content]

      if $LAST_MATCH_INFO[:is_outer_n].nil?
        old_spoiler_html label, content
      else
        block_spoiler_html label, content
      end
    end
  end

  def old_spoiler_html label, content
    <<~HTML.squish
      <div class='b-spoiler
        unprocessed'><label>#{label}</label><div
        class='content'><div class='before'></div><div
        class='inner'>#{content}</div><div
        class='after'></div></div></div>
    HTML
  end

  def block_spoiler_html label, content
    <<~HTML.squish
      <div class='b-spoiler_block to-process'
        data-dynamic='spoiler_block'><button>#{label}</button><div><p>#{content}</p></div></div>
    HTML
  end
end
