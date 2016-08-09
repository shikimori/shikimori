class I18n::NoTranslation < ArgumentError
  def initialize message
    @message = message
  end
end
