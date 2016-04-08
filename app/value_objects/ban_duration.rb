class BanDuration
  include Translation

  delegate :to_i, :zero?, :minutes, to: :value
  attr_reader :value

  # duration in minutes
  def initialize duration
    @value = if duration.kind_of? String
      parse duration
    else
      duration
    end
  end

  def to_s
    hash = to_hash
    result = []

    result << "#{hash[:years]}y" if hash[:years] > 0
    result << "#{hash[:weeks]}w" if hash[:weeks] > 0
    result << "#{hash[:days]}d" if hash[:days] > 0
    result << "#{hash[:hours]}h" if hash[:hours] > 0
    result << "#{hash[:minutes]}m" if hash[:minutes] > 0

    if result.any?
      result.join ' '
    else
      '0m'
    end
  end

  def humanize
    to_hash.each_with_object([]) do |(type, value), memo|
      next if memo.size == 2
      if memo.size == 1 && value == 0
        memo << nil
        next
      end

      if value > 0
        key = type.to_s.singularize
        duration = i18n_i "datetime.#{key}", value

        memo << "#{value} #{duration}"
      end
    end.compact.join ' '
  end

  def eql? ban_duration
    to_i == ban_duration.to_i
  end

private

  def to_hash
    {
      years: (value / (60*24 * 365)).floor,
      weeks: (((value / (60*24)).floor % 365) / 7).floor,
      days: (value / (60*24)).floor % 365 % 7,
      hours: (value / 60).floor % 24,
      minutes: value % 60
    }
  end

  def parse string
    string.strip.split(/ +/).map do |duration_part|
      kind = duration_part[-1]
      number = duration_part[0..-2].to_f

      case kind
        when 'm'
          number.to_i

        when 'h'
          (number * 60).to_i

        when 'd'
          (number * 60 * 24).to_i

        when 'w'
          (number * 60 * 24 * 7).to_i

        when 'y'
          (number * 60 * 24 * 365).to_i
      end
    end.sum
  rescue
    nil
  end
end
