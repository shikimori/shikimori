require 'i18n'

module I18n
  LOCALES = {
    'russian' => :ru,
    'english' => :en
  }

  def self.russian?
    I18n.locale == :ru
  end
end
