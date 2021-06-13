class BbCodes::Tags::CodeTag # rubocop:disable ClassLength
  BBCODE_REGEXP = %r{
    \[ code (?:=(?<language>[\w+#-]+))? \]
      (?<before> \ + | \ +[\r\n]+ | [\r\n]* )
      (?<code> .*? )
      (?<after> [\ \r\n]* )
    \[ /code \] (?<suffix> \n?)
    |
    ^ (?<markdown_opening> (?:>\ |-\ |\ \ )+ )? ``` (?<language>[\w+#-]+)? \n
      (?<code_block> .*? ) \n
    ^ (?<markdown_ending> (?:>\ |\ \ )+ )? ``` (?:\n|$)
  }mix

  MARKDOWN_REGEXP = /(?<mark>`++)(?<code>(?:(?!\k<mark>).)+)\k<mark>/

  CODE_PLACEHOLDER_1 = '!!-CODE-1-!!'
  CODE_PLACEHOLDER_2 = '!!-CODE-2-!!'

  CODE_INLINE_OPEN_TAG = "<code class='b-code_inline'>"
  CODE_INLINE_CLOSE_TAG = '</code>'

  def preprocess text
    @cache = []
    proprocess_markdown(preprocess_bbcode(text))
  end

  def postprocess text
    fixed_text = postprocess_markdown(postprocess_bbcode(text))

    raise BbCodes::BrokenTagError if @cache.any?

    fixed_text
  end

  def restore text
    text
      .gsub(CODE_PLACEHOLDER_2) { @cache.shift.original }
      .gsub(CODE_PLACEHOLDER_1) { restore_code_block @cache.shift }
  end

private

  def preprocess_bbcode text # rubocop:disable all
    text.gsub BBCODE_REGEXP do |match|
      markdown_opening = $LAST_MATCH_INFO[:markdown_opening]
      markdown_ending = $LAST_MATCH_INFO[:markdown_ending]

      if markdown_opening&.size == markdown_ending&.size
        store(
          text: $LAST_MATCH_INFO[:code] || $LAST_MATCH_INFO[:code_block],
          original: match,
          language: $LAST_MATCH_INFO[:language],
          before: $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:before],
          after: $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:after],
          suffix: $LAST_MATCH_INFO[:suffix] == "\n" ? '<br>' : '',
          markdown_opening: markdown_opening,
          markdown_ending: markdown_ending
        )

        markdown_opening ?
          markdown_opening + CODE_PLACEHOLDER_1 :
          CODE_PLACEHOLDER_1
      else
        match
      end
    end
  end

  def postprocess_bbcode text
    text.gsub CODE_PLACEHOLDER_1 do
      code = @cache.shift

      raise BbCodes::BrokenTagError if code.nil?

      if code.language
        code_highlight code_block_text(code), code.language

      elsif code_block? code.text, code.content_around
        code_highlight code_block_text(code), nil

      else
        code_inline(code.text) + code.suffix
      end
    end
  end

  def proprocess_markdown text
    text.gsub MARKDOWN_REGEXP do |match|
      store(
        text: $LAST_MATCH_INFO[:code],
        original: match
      )
      CODE_PLACEHOLDER_2
    end
  end

  def postprocess_markdown text
    text.gsub CODE_PLACEHOLDER_2 do
      code = @cache.shift
      raise BbCodes::BrokenTagError if code.nil?

      code_inline code.text
    end
  end

  def code_highlight text, language
    "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
      "data-language='#{language}'><code>#{text}</code></pre>"
  end

  def code_inline text
    "#{CODE_INLINE_OPEN_TAG}#{text}#{CODE_INLINE_CLOSE_TAG}"
  end

  def code_block? text, content_around
    text.include?("\n") || text.include?("\r") || content_around
  end

  def store( # rubocop:disable ParameterLists
    text:,
    original:,
    language: nil,
    before: nil,
    after: nil,
    suffix: nil,
    markdown_opening: nil,
    markdown_ending: nil
  )
    @cache.push OpenStruct.new(
      text: text.gsub(/\\`/, '`'),
      original: original,
      language: language,
      content_around: (!before.empty? if before) || (!after.empty? if after),
      suffix: suffix,
      markdown_opening: markdown_opening,
      markdown_ending: markdown_ending
    )
  end

  def restore_code_block code
    if code.markdown_opening
      code.original.gsub(/\A#{Regexp.escape code.markdown_opening}/, '')
    else
      code.original
    end
  end

  def code_block_text code
    if code.markdown_opening
      code.text.gsub(/^#{Regexp.escape code.markdown_ending}/, '')
    else
      code.text
    end
  end
end
