class FixName < ServiceObjectBase
  method_object :name, :full_cleanup

  BAD_SYMBOLS = %r{[%&#/\\?+><\]\[:,@"'`]+|\p{C}} # \p{C} - http://ruby-doc.org/core-2.5.0/Regexp.html
  SPACES = /[[:space:]]+|[⁤ ឵­]/
  EXTENSIONS = /
    \.
    (css|js|jpg|jpeg|png|gif|css|js|ttf|eot|otf|svg|woff|php|woff2|bmp|html)
    $
  /mix

  def call
    censor cleanup(fix(@name))
  end

private

  def censor name
    Banhammer.instance.censor name
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
