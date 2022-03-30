module I18n::RussianHack
  LOCALES = {
    'russian' => :ru,
    'english' => :en
  }

  def self.russian?
    I18n.locale == :ru
  end
end

I18n.send :prepend, I18n::RussianHack
