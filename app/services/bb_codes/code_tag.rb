class BbCodes::CodeTag
  REGEXP = %r{
    \[ code (?:=(?<language>\w+))? \]
      (?<code>.*?)
    \[ /code \]
  }mix

  CODE_PLACEHOLDER = '<<-CODE-PLACEHODLER->>'
  NO_LANGUAGE = :nohighlight

  def initialize text
    @text = text
    @cache = []
  end

  def preprocess
    @text.gsub REGEXP do |match|
      store $LAST_MATCH_INFO[:code], $LAST_MATCH_INFO[:language]
      CODE_PLACEHOLDER
    end
  end

  def postprocess text
    text.gsub CODE_PLACEHOLDER do
      code = @cache.shift

      <<-HTML.gsub(/\ *\n\ */, '').strip
        <pre class='to-process' data-dynamic='code_highlight'>
          <code class='#{code.language}'>
            #{code.content}
          </code>
        </pre>
      HTML
    end
  end

private

  def store content, language
    @cache.push(
      OpenStruct.new(content: content, language: language || NO_LANGUAGE)
    )
  end
end
