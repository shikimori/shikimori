class FixName < ServiceObjectBase
  pattr_initialize :name, :full_cleanup

  BAD_SYMBOLS = %r{[%&#/\\?+><\]\[:,@]+}
  SPACES = /[[:space:]]+|[⁤ ឵­]/
  EXTENSIONS = /
    \.
    (css|js|jpg|jpeg|png|gif|css|js|ttf|eot|otf|svg|woff|php|woff2|bmp)
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
      .strip
      .gsub(/^\.$/, 'точка')
      .gsub(EXTENSIONS, '_\1')
  end

  def fix name
    (name || '').fix_encoding.gsub(SPACES, ' ').strip
  end
end
