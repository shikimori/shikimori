class BbCodes::CodeTag
  REGEXP = %r{
    \[ code (?:=(?<language>[\w+#-]+))? \]
      (?<before> \ + | \ +[\r\n]+ | [\r\n]* )
      (?<code> .*? )
      (?<after> [\ \r\n]* )
    \[ /code \]
  }mix

  CODE_PLACEHOLDER = '<<-CODE-PLACEHODLER->>'
  NO_LANGUAGE = 'hljs nohighlight'

  def initialize text
    @text = text
    @cache = []
  end

  def preprocess
    @text.gsub REGEXP do
      store(
        $LAST_MATCH_INFO[:code],
        $LAST_MATCH_INFO[:language],
        $LAST_MATCH_INFO[:before],
        $LAST_MATCH_INFO[:after]
      )
      CODE_PLACEHOLDER
    end
  end

  def postprocess text
    text.gsub CODE_PLACEHOLDER do
      code = @cache.shift

      if code.language
        code_highlight code.text, code.language
      elsif code_block? code.text, code.content_around
        code_highlight code.text, NO_LANGUAGE
      else
        code_inline code.text
      end
    end
  end

private

  def code_highlight text, language
    "<pre class='to-process' data-dynamic='code_highlight'>"\
      "<code class='b-code #{language}'>" +
        text +
      '</code>'\
    '</pre>'
  end

  def code_inline text
    "<code>#{text}</code>"
  end

  def code_block? text, content_around
    text.include?("\n") || text.include?("\r") || content_around
  end

  def store text, language, before, after
    @cache.push OpenStruct.new(
      text: text,
      language: language,
      content_around: (!before.empty? if before) || (!after.empty? if after)
    )
  end
end
