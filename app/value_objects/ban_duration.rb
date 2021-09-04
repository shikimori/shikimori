class BanDuration
  include Translation

  delegate :to_i, :zero?, :minutes, to: :value
  attr_reader :value

  DAY_INTERVAL = 60 * 24

  # duration in minutes
  def initialize duration
    @value =
      if duration.is_a? String
        parse duration
      else
        duration
    end
  end

  def to_s
    hash = to_hash
    result = []

    result << "#{hash[:years]}y" if hash[:years].positive?
    result << "#{hash[:months]}M" if hash[:months].positive?
    result << "#{hash[:weeks]}w" if hash[:weeks].positive?
    result << "#{hash[:days]}d" if hash[:days].positive?
    result << "#{hash[:hours]}h" if hash[:hours].positive?
    result << "#{hash[:minutes]}m" if hash[:minutes].positive?

    if result.any?
      result.join ' '
    else
      '0m'
    end
  end

  def humanize
    to_hash.each_with_object([]) do |(type, value), memo|
      next if memo.size == 2

      if memo.size == 1 && value.zero?
        memo << nil
        next
      end

      next unless value.positive?

      key = type.to_s.singularize
      duration = i18n_i "datetime.#{key}", value

      memo << "#{value} #{duration}"
    end.compact.join ' '
  end

  def eql? other
    to_i == other.to_i
  end

private

  def to_hash # rubocop:disable AbcSize
    days = (value / DAY_INTERVAL).floor

    {
      years: (value / (DAY_INTERVAL * 365)).floor,
      months: ((days % 365) / 30).floor,
      weeks: ((days % 365 % 30) / 7).floor,
      days: days % 365 % 30 % 7,
      hours: (value / 60).floor % 24,
      minutes: value % 60
    }
  end

  def parse string
    string.strip.split(/ +/).sum do |duration_part|
      kind = duration_part[-1]
      number = duration_part[0..-2].to_f

      case kind
        when 'm'
          number.to_i

        when 'h'
          (number * 60).to_i

        when 'd'
          (number * DAY_INTERVAL).to_i

        when 'w'
          (number * DAY_INTERVAL * 7).to_i

        when 'M'
          (number * DAY_INTERVAL * 30).to_i

        when 'y'
          (number * DAY_INTERVAL * 365).to_i
      end
    end
  rescue StandardError
    nil
  end
end
