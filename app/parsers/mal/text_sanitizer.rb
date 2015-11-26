class Mal::TextSanitizer < ServiceObjectBase
  pattr_initialize :raw_text

  NOKOGIRI_SAVE_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_HTML |
    Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

  def call
    comments bb_codes cleanup raw_text
  end

private

  def cleanup text
    fix_phrases fix_tags fix_new_lines specials fix_html text.strip
  end

  def bb_codes text
    bb_other bb_source bb_spoiler bb_center bb_entry text
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

  def bb_other text
    text
      .gsub(%r(<strong>(.*?)</strong>)mix, '[b]\1[/b]')
      .gsub(%r(<b>(.*?)</b>)mix, '[b]\1[/b]')
      .gsub(%r(<i>(.*?)</i>)mix, '[i]\1[/i]')
      .gsub(%r(<img \s class="userimg" \s data-src="(.*?)">)mix,
        '[img]\1[/img]')
      .gsub(
        %r(<div \s style="text-align: \s right;">(.*?)<!--right-->\n?</div>)mix,
        '[right]\1[/right]'
      )
      .gsub(/\n/, '[br]')
  end

  def bb_entry text
    text.gsub %r(
      <a\shref="http://myanimelist.net/(?<type>anime|manga|character|people)
        (?:
          .php\?id=(?<id>\d+) |
          / (?<id>\d+) / \w+
        )
      ">
        (?<name>[^<]+)
      </a>
    )mix do
      type = $~[:type] == 'people' ? 'person' : $~[:type]
      "[#{type}=#{$~[:id]}]#{$~[:name]}[/#{type}]"
    end
  end

  def bb_center text
    text.gsub %r(
      <div\sstyle="text-align:\scenter;">
        (.*?)
      <!--center-->\n?</div>
    )mix, '[center]\1[/center]'
  end

  def bb_spoiler text
    text.gsub %r(
      (?: <div \s class="spoiler .*? value="Hide \s spoiler"> )
        ( .*? )
      (?: <!--spoiler-->(?:</span>)?\n?</div> )
    )mix, '[br][spoiler]\1[/spoiler]'
  end

  def bb_source text
    text
      .gsub %r(
        \n* \(?
          (?:
            source |
            written |
            taken \s from |
            retrieved \s from |
            description \s from
            adapted \s from
          ) \b
          \s* :? \s*
          ("|'|)
          (?:
            (?:<!--link-->)?<a [^>]*? href="(?<url>.*?)" [^>]*? >.*?</a>
               .*{0,8} ("|'|) (?=\Z|\)) |
            (?<text> .{0,60}? ) ("|'|) (?=\Z|\)
            )
          )
        \)? \Z
      )mix do |match|
        "[br][source]#{$~[:url] || $~[:text]}[/source]"
      end
      .gsub(%r(
        \n* \(?
          (?:<!--link-->)?<a [^>]*? href="(.*?)" [^>]*? >
            .*?
          </a>
        \)? [^\r\n]{0,8} \Z
      )mix, '[br][source]\1[/source]')
  end

  def fix_tags text
    text
      .gsub(%r{<span \s style=".*">(.*?)</span>}mix, '\1')
      .strip
  end

  # TODO
  def fix_phrases text
    text
      .gsub(%r(<(?:strong|b)>Note:</(?:strong|b)>.*)mix, '')
      .gsub(/no synopsis (?:information)? has been added[\s\S]*/i, '')
      .gsub(/no biography written[\s\S]*/i, '')
      .gsub(/no summary yet[\s\S]*/i, '')
      .strip
      # .gsub(/=Tricks=[\s\S]*/i, '')
      # .strip
      # .gsub(/(<br \/>)+$/m, '')
      # .gsub(/(<br \/?>){2}+/m, '<br />')
      # .gsub(/<div class=\"border_top\"[\s\S]*<\/div>/, '') # Naruto: Shippuuden (id: 1735)
      # .gsub(/<!--.*?-->/mix, '') # <!-- comment -->
      # .strip
  end

  def fix_new_lines text
    text
      .gsub(/<br>(?: \r\n | [\r\n] )/mix, '<br>')
      .gsub(/\r\n/, '<br>')
      .gsub(/[\n\r]/, '<br>')
      .gsub(/<br>/mix, "\n")
      .strip
  end

  def fix_html text
    Nokogiri::HTML::DocumentFragment
      .parse(text)
      .to_html(save_with: NOKOGIRI_SAVE_OPTIONS)
  end
end
