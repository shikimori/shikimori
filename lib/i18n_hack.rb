require 'i18n'

module I18n
  LOCALES = {
    'russian' => :ru,
    'english' => :en
  }

  def self.locale_from_language language
    LOCALE[language.to_s]
  end

  def self.russian?
    I18n.locale == :ru
  end
end
