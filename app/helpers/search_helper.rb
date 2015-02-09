module SearchHelper
  def self.unescape string
    (string || '').fix_encoding
        .gsub(/\+/, ' ')
        .strip
        .gsub('(l)', '+')
        .gsub('(b)', '\\')
        .gsub('(s)', '/')
        .gsub('(d)', '.')
        .gsub('(p)', '%')
        .sub(/[ \\]+$/, '')
        .gsub('ё', 'е')
        .gsub('Ё', 'Е')
        .strip
  end
end
