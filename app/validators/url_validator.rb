class UrlValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    begin
      uri = URI.parse value
      resp = uri.is_a? URI::HTTP
    rescue URI::InvalidURIError
      resp = false
    end

    unless resp == true
      record.errors[attribute] << (
        options[:message] || I18n.t('activerecord.errors.messages.invalid')
      )
    end
  end
end
