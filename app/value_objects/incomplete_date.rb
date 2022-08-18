class IncompleteDate
  include ShallowAttributes
  include Types::JsonbActiveModel
  # include ActiveModel::Validations

  NO_YEAR = 1901

  attribute :year, Integer, allow_nil: true
  attribute :month, Integer, allow_nil: true
  attribute :day, Integer, allow_nil: true

  def human
    return unless date

    @human ||= (
      year ?
        localized_date :
        localized_date.gsub(" #{NO_YEAR}", '')
    ).strip
  end

private

  def date
    return unless year || month

    @date ||= Date.new year || NO_YEAR, month, day
  end

  def localized_date
    I18n.l date, format: :human
  end
end
