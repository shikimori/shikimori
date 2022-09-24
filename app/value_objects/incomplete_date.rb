class IncompleteDate
  include ShallowAttributes
  include Types::JsonbActiveModel

  attribute :year, Integer, allow_nil: true
  attribute :month, Integer, allow_nil: true
  attribute :day, Integer, allow_nil: true

  SPACES_CLEANUP_REGEXP = /  /

  def human
    return unless year || month || day

    I18n.l(date, format: date_format)
      .strip
      .gsub(SPACES_CLEANUP_REGEXP, ' ')
  end

private

  def date
    Date.new year || 1901, month || 1, day || 1
  end

  def date_format # rubocop:disable all
    if year && month && day
      :human
    elsif year && month
      :human_month_year
    elsif month && day
      :human_day_month
    else
      '%Y'
    end
  end
end
