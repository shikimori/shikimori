class BbCodes::Tags::SpoilerTag
  include Singleton

  LABEL_REGEXP = /(?:=(?<label>[^\[\]\n\r]+?))?/
  REGEXP = %r{
    (?<outer>^|\n|</p>|</div>|#{BbCodes::Tags::DivTag::TAG_START_REGEXP.source})?
    \[spoiler #{LABEL_REGEXP.source} \]
      \n?
      (?<content>
        (?:
          (?! \[/?spoiler #{LABEL_REGEXP.source} \] ) (?>[\s\S])
        )+
      )
      \n?
    \[/spoiler\]
  }xi

  TEXT_CONTENT_REGEXP = /\A[^\n\[\]]++\Z/
  INLINE_LABELS = ['spoiler', 'спойлер', nil]

  def format text
    spoiler_to_html text, 0
  end

private

  def spoiler_to_html text, nesting
    return text if nesting > 5

    text = spoiler_to_html text, nesting + 1

    text.gsub(REGEXP) do |_match|
      label = $LAST_MATCH_INFO[:label] || I18n.t('markers.spoiler')
      content = $LAST_MATCH_INFO[:content]
      outer = $LAST_MATCH_INFO[:outer]

      if outer.nil? && inline?(label, content)
        inline_spoiler_html content
      elsif outer.nil?
        old_spoiler_html label, content
      else
        block_spoiler_html label, content, outer
      end
    end
  end

  def inline_spoiler_html content
    <<~HTML.squish
      <span class='b-spoiler_inline to-process'
        data-dynamic='spoiler_inline'><span>#{content}</span></span>
    HTML
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

  def block_spoiler_html label, content, outer
    outer +
      <<~HTML.squish
        <div class='b-spoiler_block to-process'
          data-dynamic='spoiler_block'><button>#{label}</button><div>#{content}</div></div>
      HTML
  end

  def inline? label, content
    label.in?(INLINE_LABELS) && content.match?(TEXT_CONTENT_REGEXP)
  end
end
