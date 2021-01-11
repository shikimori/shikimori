class FixName < ServiceObjectBase
  method_object :name, :full_cleanup

  BAD_SYMBOLS = %r{[%&#/\\?+><\]\[:,@"'`]+} # \p{C} - http://ruby-doc.org/core-2.5.0/Regexp.html
  SPACES = /(?:[[:space:]]|[⁤ ឵⠀ᅠ­]|\p{C})+/
  ALL_EXTENSIONS = %w[
    css js jpg jpeg png gif css js ttf eot otf svg woff php woff2 bmp html
    rar zip gz tar rss
  ]
  EXTENSIONS = /
    \.(#{ALL_EXTENSIONS.join('|')})$
  /mix
  SPAM_WORDS = Users::CheckHacked::SPAM_DOMAINS

  def call
    remove_spam censor(cleanup(fix(@name)))
  end

private

  def censor name
    Banhammer.instance.censor name, 'x'
  end

  def remove_spam name
    name.gsub BbCodes::Text::BANNED_DOMAINS, BbCodes::Text::BANNED_TEXT
  end

  def cleanup name
    return name unless @full_cleanup

    name
      .gsub(BAD_SYMBOLS, '')
      .strip
      .gsub(/^\.$/, 'точка')
      .gsub(EXTENSIONS, '_\1')
  end

  def fix name
    (name.is_a?(String) ? name : name.to_s)
      .fix_encoding
      .gsub(SPACES, ' ')
      .gsub(/./) { |v| v.ord.between?(917_760, 917_999) ? ' ' : v }
      .strip
  end
end
