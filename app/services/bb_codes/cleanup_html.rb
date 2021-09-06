class BbCodes::CleanupHtml
  method_object :text

  NOKOGIRI_OPTIONS = Nokogiri::XML::Node::SaveOptions::AS_HTML |
    Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

  SMILEY_REGEXP = %r{
    (<img\ [^>]*?\ class="smiley"\ ?/?>) \s*
    <img\ [^>]*?\ class="smiley"\ ?/?>
    (?:\s*<img.*?class="smiley"\ ?/?>)+
  }mix

  def call
    cleanup(@text)
  end

private

  def cleanup text
    # Nokogiri::HTML::DocumentFragment
    #   .parse(fix(text))
    #   .to_html(save_with: NOKOGIRI_OPTIONS)
    #   .html_safe

    # NOTE: `Nokogiri.HTML5` used from nokogumbo gem
    # it fixes html much better in comparison to Nokogiri
    Nokogiri::HTML5(fix(text))
      .css('body')
      .inner_html
      .html_safe

  # LoadError: cannot load such file -- enc/trans/single_byte
  rescue StandardError => e
    if e.message.include? 'cannot load such file'
      text
    elsif e.message.include? 'Document tree depth limit exceeded'
      text
    else
      raise
    end
  end

  def fix text
    text
      .gsub(/!!!+/, '!')
      .gsub(/\?\?\?+/, '?')
      .gsub(/\.\.\.\.+/, '.')
      .gsub(/\)\)\)+/, ')')
      .gsub(/\(\(\(+/, '(')
      .gsub(SMILEY_REGEXP, '\1')
  end
end
