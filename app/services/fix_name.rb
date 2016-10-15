class FixName < ServiceObjectBase
  pattr_initialize :name

  BAD_SYMBOLS = %r{ [%&#/\\?+><\]\[:,@]+ }mix
  SPACES = /[[:space:]]+|[⁤ ឵]/
  EXTENSIONS = /
    \.
    (css|js|jpg|jpeg|png|gif|css|js|ttf|eot|otf|svg|woff|php|woff2|bmp)
    $
  /mix

  def call
    Banhammer.instance.censor(fixed_name)
  end

private

  def fixed_name
    (@name || '')
      .fix_encoding
      .gsub(BAD_SYMBOLS, '')
      .gsub(SPACES, ' ')
      .strip
      .gsub(/^\.$/, 'точка')
      .gsub(EXTENSIONS, '_\1')
  end
end
