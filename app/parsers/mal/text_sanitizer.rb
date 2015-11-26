class Mal::TextSanitizer < ServiceObjectBase
  pattr_initialize :raw_text

  NOKOGIRI_SAVE_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_HTML |
    Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

  def call
    specials bb_codes cleanup raw_text
  end

private

  def cleanup text
    fix_phrases(
      fix_tags(
        fix_new_lines(
          fix_html(
            text.strip))))
  end

  def bb_codes text
    bb_other bb_spoiler bb_center bb_entry text
  end

  def specials text
    text
      .gsub('&amp;#039;', "'")
      .gsub(/<!--.*?-->/mix, '') # <!-- comment -->
  end

  def bb_other text
    text
      .gsub(/\n/, '[br]')
      .gsub(%r(<strong>(.*?)</strong>)mix, '[b]\1[/b]')
      .gsub(%r(<b>(.*?)</b>)mix, '[b]\1[/b]')
      .gsub(%r(<i>(.*?)</i>)mix, '[i]\1[/i]')
  end

  def bb_entry text
    text.gsub %r{
      <a\shref="http://myanimelist.net/(?<type>anime|manga|character|people)
        (?:
          .php\?id=(?<id>\d+) |
          / (?<id>\d+) / \w+
        )
      ">
        (?<name>[^<]+)
      </a>
    }mix do
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
      (?: <div \s class="spoiler .*? value="Hide\sspoiler"> )
        ( .*? )
      (?: <!--spoiler-->(?:</span>)?\n?</div> )
    )mix, '[br][spoiler]\1[/spoiler]'
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
      .strip

      # .gsub(/<br \/>(<br \/>)?(\(|\[)?source[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)?\[written[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)?(\(|- ?)?from[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)?Taken from[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)?\(description from[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)?\(adapted from[\s\S]*/i, '')
      # .gsub(/<br \/>(<br \/>)<strong>Note:<\/strong><br \/>[\s\S]*/i, '')
      # .gsub(/=Tricks=[\s\S]*/i, '')
      # .gsub(/No synopsis has been added for this .*? yet[\s\S]*/i, '')
      # .gsub(/No biography written.[\s\S]*/i, '')
      # .gsub(/No summary yet.[\s\S]*/i, '')
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
