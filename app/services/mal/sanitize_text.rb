# rubocop:disable ClassLength
class Mal::SanitizeText
  NOKOGIRI_SAVE_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_HTML |
    Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

  ENTRY_REGEXP = %r{
    <a [^>]*? href="
      https?://myanimelist.net/(?<type>anime|manga|character|people)
      (?:
        .php\?id=(?<id>\d+) |
        / (?<id>\d+) (?: / [\w:/!-]* )?
      )
    " [^>]*? >
      (?:<[ib]>)?
      (?<name>[^<]+)
      (?:</[ib]>)?
    </a>
  }mix

  LINK_REGEXP = %r{
    <a [^>]*? href="(?<url>[^"]+)" [^>]*? >
      (?<name>[^<]*)
    </a>
  }mix

  SOURCE_REGEXP_1 = %r{
    \n*
    (?<prefix>(?:<(?:div|span)[^>]+>)+)?
    \(?
      (?: <[bi]> )?
      (?:
        source |
        written |
        taken \s from |
        retrieved \s from |
        description \s from
        adapted \s from
      ) \b

      (?: </[bi]> )? \s* :? \s*
      (?: </[bi]> )? \s* :? \s*

      ["']?
      (?:
        (?:<!--link-->)?<a [^>]*? href="(?<url>.*?)" [^>]*? >.*?</a>
        .*{0,8}
        |
        (?<text> [^<]{0,100}? )
      )
      ["']?
      (?= \Z|[)\[<] )
    \)?
    (?<postfix>(?:</(?:div|span)>)+)?
    \Z
  }mix

  SOURCE_REGEXP_2 = %r{
    (?: ([\s\S]{300} \n*+) | \n+ )
    \(?
      (?:<!--link-->)?<a [^>]*? href="(.*?)" [^>]*? >
        .*?
      </a>
    \)? [^\r\n]{0,8} \Z
  }mix

  MOREINFO_LINK_REGEXP = %r{
    <a [^>]*? href="https?://myanimelist.net/[^"]*?/moreinfo/?" [^>]*? >
      (.*?)
    </a>
  }mix
  DOUBLE_LINK_REGEXP = %r{
    <a [^>]*? href="([^"]+)" [^>]*? ></a>
    (
      <a [^>]*? href="(\1)" [^>]*? >.*?</a>
    )
  }mix

  POSITION_TAG_REGEXP = %r{
    <div \s style="text-align: \s (right|center);">
      ( .*? ) (?:<!--right-->)?\n?
    </div>
  }mix

  COLOR_TAG_REGEXP = %r{
    <span \s style="color: \s ([^">]+);">
      ( .*? )
    </span>
  }

  SPOILER_REGEXP = %r{
    \n*
    (?: <div \s class="spoiler .*? value="Hide \s [^"<>]*"> )
      ( .*? )
    (?: </span>\n?</div> )
  }mix

  method_object :raw_text

  def call
    finalize(comments(bb_codes(cleanup(finalize(@raw_text)))))
  end

private

  def cleanup text
    fix_links fix_phrases fix_tags fix_new_lines specials fix_html text
  end

  def bb_codes text
    bb_other bb_link bb_source bb_spoiler bb_center bb_entry text
  end

  def specials text
    text
      .gsub('&amp;', '&')
      .gsub('&quot;', '"')
      .gsub('&#039;', "'")
  end

  def comments text
    text.gsub(/<!--.*?-->/mix, '') # <!-- comment -->
  end

  def finalize text
    text.gsub(/
      \A (\s | \[br\] | <br> )+
      |
      ( \s | \[br\] | <br> )+ \Z
    /mix, '')
  end

  def bb_other text
    text
      .gsub(%r{<strong>(.*?)</strong>}mix, '[b]\1[/b]')
      .gsub(%r{<b>(.*?)</b>}mix, '[b]\1[/b]')
      .gsub(%r{<i>(.*?)</i>}mix, '[i]\1[/i]')
      .gsub(%r{<em>(.*?)</em>}mix, '[i]\1[/i]')
      .gsub(/<img \s class="userimg" \s (?:data-)?src="(.*?)">/mix,
        '[img]\1[/img]')
      .gsub(POSITION_TAG_REGEXP, '[\1]\2[/\1]')
      .gsub(COLOR_TAG_REGEXP, '[color=\1]\2[/color]')
      .gsub(/\n/, '[br]')
  end

  def bb_entry text
    text.gsub ENTRY_REGEXP do
      type = $LAST_MATCH_INFO[:type]
      type = 'person' if type == 'people'
      "[#{type}=#{$LAST_MATCH_INFO[:id]}]#{$LAST_MATCH_INFO[:name]}[/#{type}]"
    end
  end

  def bb_link text
    text.gsub LINK_REGEXP do |match|
      if match.include? 'myanimelist'
        match
      else
        "[url=#{$LAST_MATCH_INFO[:url]}]#{$LAST_MATCH_INFO[:name]}[/url]"
      end
    end
  end

  def bb_center text
    text.gsub %r{
      <div\sstyle="text-align:\scenter;">
        (.*?)
      <!--center-->\n?</div>
    }mix, '[center]\1[/center]'
  end

  def bb_spoiler text
    text
      .gsub(SPOILER_REGEXP, '[br][spoiler]\1[/spoiler]')
      .gsub(SPOILER_REGEXP, '[br][spoiler]\1[/spoiler]')
      .gsub(SPOILER_REGEXP, '[br][spoiler]\1[/spoiler]')
      .gsub(SPOILER_REGEXP, '[br][spoiler]\1[/spoiler]')
      .gsub(SPOILER_REGEXP, '[br][spoiler]\1[/spoiler]')
  end

  def bb_source text
    text
      .gsub(SOURCE_REGEXP_1) do
        source = $LAST_MATCH_INFO[:url] || $LAST_MATCH_INFO[:text]
        "[source]#{source}[/source]"
      end
      .gsub(SOURCE_REGEXP_2, '\1[source]\2[/source]')
  end

  def fix_tags text
    text
      .gsub(%r{<span \s style=".*?">(.*?)</span>}mix, '\1')
      .gsub(%r{<span \s style=".*?">(.*?)</span>}mix, '\1')
  end

  def fix_phrases text
    text
      .gsub(%r{<(?:strong|b)>Note:</(?:strong|b)>.*}mix, '')
      .gsub(/no synopsis (?:information)? has been added[\s\S]*/i, '')
      .gsub(/no biography written[\s\S]*/i, '')
      .gsub(/no summary yet[\s\S]*/i, '')
      .gsub(/no summary yet[\s\S]*/i, '')
      .gsub(/\[Written by MAL Rewrite\]/i, '')
  end

  def fix_new_lines text
    text
      .gsub(/<br>(?: \r\n | [\r\n] )/mix, '<br>')
      .gsub(/\r\n/, '<br>')
      .gsub(/[\n\r]/, '<br>')
      .gsub(/<br>/mix, "\n")
  end

  def fix_links text
    text
      .gsub(MOREINFO_LINK_REGEXP, '\1')
      .gsub(DOUBLE_LINK_REGEXP, '\2')
  end

  def fix_html text
    Nokogiri::HTML::DocumentFragment
      .parse(text)
      .to_html(save_with: NOKOGIRI_SAVE_OPTIONS)
  end
end
# rubocop:enable ClassLength
