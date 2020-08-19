class BbCodes::Paragraphs
  method_object :text

  LINE_SIZE = 110
  MULTILINE_BBCODES = BbCodes::Markdown::ListQuoteParser::MULTILINE_BBCODES

  PARAGRAPH_PRE_BR_TAGS = /
    (?: \r\n|\r|\n|<br> )?
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
      (?! \r\n|\r|\n|<br> )
    )
  /mix

  PARAGRAPH_FULL_REGEXP = %r{(?<line>.+?)(?:\n|<br\s?/?>|&lt;br\s?/?&gt;|$)}x
  PARAGRAPH_MIN_REGEXP = %r{\r\n|\n|<br\s?/?>|&lt;br\s?/?&gt;}

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

      if line.size >= LINE_SIZE && !line.match(/(?:^|PLACEHODLER->>) *\[\*\]/) &&
          unbalanced_tags.zero?
        "[p]#{line.gsub(PARAGRAPH_MIN_REGEXP, '')}[/p]"
      else
        line
      end
    end
  end

  def count_tags line
    %i[quote list spoiler center].inject(0) do |memo, tag|
      memo + (line.scan("[#{tag}").size - line.scan("[/#{tag}]").size).abs
    end
  end
end
