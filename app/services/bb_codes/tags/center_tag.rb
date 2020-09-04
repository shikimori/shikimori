class BbCodes::Tags::CenterTag
  include Singleton

  REGEXP = %r{
    \[center\]
      (?<content>
        (?:
          (?! \[/center\] ) (?>.)
        )+
      )
    \[/center\] \n?
  }mix

  MAX_NESTING = 3

  def format text
    bbcode_to_html(text, 1).first
  end

private

  def bbcode_to_html text, nesting
    return [text, true] if nesting > MAX_NESTING

    text, were_changed = bbcode_to_html text, nesting + 1
    return [text, were_changed] unless were_changed

    is_changed = false
    text = text.gsub(REGEXP) do |_match|
      is_changed = true
      "<center>#{$LAST_MATCH_INFO[:content]}</center>"
    end

    [text, is_changed]
  end
end
