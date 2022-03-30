module I18n::RussianCheck
  def russian?
    I18n.locale == :ru
  end
end

I18n.send :extend, I18n::RussianCheck
