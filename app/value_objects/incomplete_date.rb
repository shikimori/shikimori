class IncompleteDate
  include ShallowAttributes
  include Types::JsonbActiveModel
  include Comparable

  class NilInteger
    def coerce value, _options = {}
      value.to_i if value.present?
    end
  end

  module ComputedField
    def self.[] field
      ::Module.new do
        define_method :"#{field}=" do |value|
          super value
          send(:"#{field}_computed=", (send(field).date if send(field).present?))
          send field
        end
      end.freeze
    end
  end

  attribute :year, NilInteger, allow_nil: true
  attribute :month, NilInteger, allow_nil: true
  attribute :day, NilInteger, allow_nil: true

  SPACES_CLEANUP_REGEXP = /  /

  def self.new object = nil
    return super({}) if object.blank?

    case object
      when String
        date = Date.parse object
        super year: date.year, month: date.month, day: date.day

      when Date, Time, DateTime, ActiveSupport::TimeWithZone
        super year: object.year, month: object.month, day: object.day

      else
        super object
    end
  end

  def human
    return if blank?

    I18n.l(date, format: date_format)
      .strip
      .gsub(SPACES_CLEANUP_REGEXP, ' ')
  end

  def blank?
    !(year || month || day)
  end

  def date
    if blank?
      nil
    else
      @date ||= Date.new year || 1901, month || 1, day || 1
    end
  end

  # make it comparable to dates
  def == other
    if other.respond_to? :to_date
      other.to_date == date
    else
      super other
    end
  end
  delegate :<=>, to: :date
  def coerce value
    [
      value.respond_to?(:to_date) ? value.to_date : value,
      date
    ]
  end

private

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
