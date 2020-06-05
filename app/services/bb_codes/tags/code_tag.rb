class BbCodes::Tags::CodeTag
  REGEXP = %r{
    \[ code (?:=(?<language>[\w+#-]+))? \]
      (?<before> \ + | \ +[\r\n]+ | [\r\n]* )
      (?<code> .*? )
      (?<after> [\ \r\n]* )
    \[ /code \]
  }mix

  CODE_PLACEHOLDER = '<<-CODE-PLACEHODLER->>'

  class BrokenTagError < RuntimeError
  end

  def initialize text
    @text = text
    @cache = []
  end

  def preprocess
    @text.gsub REGEXP do |match|
      store(
        $LAST_MATCH_INFO[:code],
        $LAST_MATCH_INFO[:language],
        $LAST_MATCH_INFO[:before],
        $LAST_MATCH_INFO[:after],
        match
      )
      CODE_PLACEHOLDER
    end
  end

  def postprocess text
    fixed_text = text.gsub CODE_PLACEHOLDER do
      code = @cache.shift

      raise BrokenTagError if code.nil?

      if code.language
        code_highlight code.text, code.language
      elsif code_block? code.text, code.content_around
        code_highlight code.text, nil
      else
        code_inline code.text
      end
    end

    raise BrokenTagError if @cache.any?

    fixed_text
  end

  def restore text
    text.gsub CODE_PLACEHOLDER do
      @cache.shift.original
    end
  end

private

  def code_highlight text, language
    "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
      "data-language='#{language}'><code>#{text}</code></pre>"
  end

  def code_inline text
    "<code class='inline'>#{text}</code>"
  end

  def code_block? text, content_around
    text.include?("\n") || text.include?("\r") || content_around
  end

  def store text, language, before, after, original
    @cache.push OpenStruct.new(
      text: text,
      language: language,
      content_around: (!before.empty? if before) || (!after.empty? if after),
      original: original
    )
  end
end
