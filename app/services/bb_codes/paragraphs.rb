class BbCodes::Paragraphs
  method_object :text

  LINE_SIZE = 110

  PARAGRAPH_PRE_BR_TAGS = /
    (?: \n|^ )?
    (?<tag> \[\*\] )
  /mix
  PARAGRAPH_PRE_SPACE_TAGS = /
    [ ]+
    (?<tag> \[\*\] )
  /mix
  PARAGRAPH_POST_BR_TAGS = /
    (?<tag>
      \[
        (?:#{MULTILINE_BBCODES.join('|')})
        (\[.*?\] | [^\]])*
      \]
      (?! \n|\$ )
    )
  /mix

  PARAGRAPH_FULL_REGEXP = /(?<line>.+?)(?:\n|$)/x
  PARAGRAPH_MIN_REGEXP = /\n/

  LIST_OR_PLACEHOLDER_REGEXP = /(?:^|PLACEHODLER->>)(?: *\[\*\]|[-*+>])/

  def call
    replace_paragraphs paragraph_tags(text)
  end

private

  # препроцессинг контента, чтобы теги параграфов не разрывали содержимое тегов
  def paragraph_tags text
    text
      .gsub(PARAGRAPH_PRE_SPACE_TAGS) { $LAST_MATCH_INFO[:tag] }
      .gsub(PARAGRAPH_PRE_BR_TAGS) { "\n#{$LAST_MATCH_INFO[:tag]}" }
      .gsub(PARAGRAPH_POST_BR_TAGS) { "#{$LAST_MATCH_INFO[:tag]}\n" }
  end

  def replace_paragraphs text
    text.gsub(PARAGRAPH_FULL_REGEXP) do |line|
      unbalanced_tags = count_tags(line)

      if line.size >= LINE_SIZE && unbalanced_tags.zero? &&
          !line.match?(LIST_OR_PLACEHOLDER_REGEXP)
        "[p]#{line.gsub(PARAGRAPH_MIN_REGEXP, '')}[/p]"
      else
        line
      end
    end
  end

  def count_tags line
    MULTILINE_BBCODES.inject(0) do |memo, tag|
      memo + (line.scan("[#{tag}").size - line.scan("[/#{tag}]").size).abs
    end
  end
end
