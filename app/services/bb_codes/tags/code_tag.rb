class BbCodes::Tags::CodeTag # rubocop:disable ClassLength
  BBCODE_REGEXP = %r{
    \[ code (?:=(?<language>[\w+#-]+))? \]
      (?<before> \ + | \ +[\r\n]+ | [\r\n]* )
      (?<code> .*? )
      (?<after> [\ \r\n]* )
    \[ /code \] (?<suffix> \n?)
    |
    ^ ``` (?<language>[\w+#-]+)? \n
      (?<code_block> .*? ) \n
    ^ ``` (?:\n|$)
  }mix

  MARKDOWN_REGEXP = /(?<mark>`++)(?<code>(?:(?!\k<mark>).)+)\k<mark>/

  CODE_PLACEHOLDER_1 = '<<-CODE-1-PLACEHODLER->>'
  CODE_PLACEHOLDER_2 = '<<-CODE-2-PLACEHODLER->>'

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
      .gsub(CODE_PLACEHOLDER_1) { @cache.shift.original }
  end

private

  def preprocess_bbcode text
    text.gsub BBCODE_REGEXP do |match|
      store(
        $LAST_MATCH_INFO[:code] || $LAST_MATCH_INFO[:code_block],
        $LAST_MATCH_INFO[:language],
        $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:before],
        $LAST_MATCH_INFO[:code_block] ? 'z' : $LAST_MATCH_INFO[:after],
        $LAST_MATCH_INFO[:suffix] == "\n" ? '<br>' : '',
        match
      )
      CODE_PLACEHOLDER_1
    end
  end

  def postprocess_bbcode text
    text.gsub CODE_PLACEHOLDER_1 do
      code = @cache.shift

      raise BbCodes::BrokenTagError if code.nil?

      if code.language
        code_highlight code.text, code.language
      elsif code_block? code.text, code.content_around
        code_highlight code.text, nil
      else
        code_inline(code.text) + code.suffix
      end
    end
  end

  def proprocess_markdown text
    text.gsub MARKDOWN_REGEXP do |match|
      store(
        $LAST_MATCH_INFO[:code],
        nil,
        nil,
        nil,
        nil,
        match
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
    text,
    language,
    before,
    after,
    suffix,
    original
  )
    @cache.push OpenStruct.new(
      text: text.gsub(/\\`/, '`'),
      language: language,
      content_around: (!before.empty? if before) || (!after.empty? if after),
      suffix: suffix,
      original: original
    )
  end
end
