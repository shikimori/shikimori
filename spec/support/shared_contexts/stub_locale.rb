shared_context :stub_locale do |locale|
  let!(:default_locale) { I18n.locale }
  before { I18n.locale = locale }
  after { I18n.locale = default_locale }
end
