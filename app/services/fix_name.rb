class FixName < ServiceObjectBase
  method_object :name, :full_cleanup

  BAD_SYMBOLS = %r{[%&#/\\?+><\]\[:,@"'`]+|\p{C}} # \p{C} - http://ruby-doc.org/core-2.5.0/Regexp.html
  SPACES = /[[:space:]]+|[⁤ ឵­]/
  ALL_EXTENSIONS = %w[
    css js jpg jpeg png gif css js ttf eot otf svg woff php woff2 bmp html
    rar zip gz tar
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
    Banhammer.instance.censor name
  end

  def remove_spam name
    name.gsub BbCodes::Text::SPAM_DOMAINS, 'spam.domain'
  end

  def cleanup name
    return name unless @full_cleanup
    name
      .gsub(BAD_SYMBOLS, '')
      .tr('⠀', ' ')
      .strip
      .gsub(/^\.$/, 'точка')
      .gsub(EXTENSIONS, '_\1')
  end

  def fix name
    (name.is_a?(String) ? name : name.to_s).fix_encoding.gsub(SPACES, ' ').strip
  end
end
