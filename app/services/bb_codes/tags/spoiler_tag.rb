class BbCodes::Tags::SpoilerTag # rubocop:disable ClassLength
  include Singleton

  LABEL_REGEXP = %r{
    (?:
      = (?<label>
        (?:
          <span\ class='b-entry-404'>.+?</span> |
          [^\[\]\n\r]
        )+?
      )
    )?
  }x
  REGEXP = %r{
    (?<prefix>
      ^ | \n | #{BbCodes::BLOCK_TAG_EDGE_PREFIX_REGEXP.source}
    )?
    \[(?<tag>spoiler(?:_block|_v1)?) #{LABEL_REGEXP.source}
      ((?<fullwidth>\ is-fullwidth)|(?<centered>\ is-centered))*
    \]
      \n?
      (?<content>
        (?:
          (?! \[/?spoiler(?:_block|_v1)? #{LABEL_REGEXP.source} \] ) (?>.)
        )+
      )
    \[/\k<tag>\]
    (?<suffix>\n)?
  }mix

  TAG_REGEXP = %r{</?\w+}

  TEXT_CONTENT_REGEXP = /\A[^\n\[\]]++\Z/
  INLINE_LABELS = ['spoiler', 'спойлер', nil]
  MAX_DEFAULT_SPOILER_INLINE_SIZE = 100

  INLINE_TAG_OPEN = "<span class='b-spoiler_inline to-process' "\
    "data-dynamic='spoiler_inline' tabindex='0'>"
  INLINE_TAG_CLOSE = '</span>'

  MAX_NESTING = 5

  def format text
    bbcode_to_html(text, 1).first
  end

private

  def bbcode_to_html text, nesting # rubocop:disable all
    return [text, true] if nesting > MAX_NESTING

    text, were_changed = bbcode_to_html text, nesting + 1
    return [text, were_changed] unless were_changed

    is_changed = false
    text = text.gsub(REGEXP) do |_match|
      is_changed = true

      tag = $LAST_MATCH_INFO[:tag]
      label = $LAST_MATCH_INFO[:label]&.strip || I18n.t('markers.spoiler')
      prefix = $LAST_MATCH_INFO[:prefix]
      is_fullwidth = !!($LAST_MATCH_INFO[:fullwidth])
      is_centered = !!($LAST_MATCH_INFO[:centered])
      suffix = $LAST_MATCH_INFO[:suffix] || ''
      content = $LAST_MATCH_INFO[:content].gsub(/\n\Z/, '') # cleanup similar to [center]

      to_html tag, label, content, prefix, is_fullwidth, is_centered, suffix
    end

    [text, is_changed]
  end

  def to_html tag, label, content, prefix, is_fullwidth, is_centered, suffix # rubocop:disable all
    method_name =
      if tag == 'spoiler_block'
        :block_spoiler_html
      elsif tag == 'spoiler_v1'
        :old_spoiler_html
      elsif prefix.nil? && inline?(label, content)
        :inline_spoiler_html
      elsif prefix.nil? || label.match?(TAG_REGEXP)
        :old_spoiler_html
      else
        :block_spoiler_html
      end

    suffix = '' if method_name == :block_spoiler_html

    (prefix || '') +
      send(method_name, label, content, is_fullwidth, is_centered) +
      (suffix || '')
  end

  def inline_spoiler_html _label, content, _is_fullwidth, _is_centered
    INLINE_TAG_OPEN +
      "<span>#{content}</span>" +
    INLINE_TAG_CLOSE
  end

  def old_spoiler_html label, content, _is_fullwidth, _is_centered
    "<div class='b-spoiler unprocessed'>" \
      "<label>#{label}</label>" \
      "<div class='content'>" \
        "<div class='before'></div>" \
        "<div class='inner'>#{content}</div>" \
        "<div class='after'></div>" \
      '</div>' \
    '</div>'
  end

  def block_spoiler_html label, content, is_fullwidth, is_centered
    fullwidth = ' is-fullwidth' if is_fullwidth
    centered = ' is-centered' if is_centered

    "<div class='b-spoiler_block to-process#{fullwidth}#{centered}' "\
      "data-dynamic='spoiler_block'>" \
      "<span tabindex='0'>#{label}</span>" \
      "<div>#{content.rstrip}</div>" \
    '</div>'
  end

  def inline? label, content
    label.in?(INLINE_LABELS) && content.match?(TEXT_CONTENT_REGEXP) &&
      !content.match?(BbCodes::Markdown::SpoilerInlineParser::FORBIDDEN_BBCODES_REGEXP) &&
      content.size <= MAX_DEFAULT_SPOILER_INLINE_SIZE
  end
end
