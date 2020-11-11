class Animes::Filters::Terms
  include Enumerable

  def initialize value, dry_type
    @dry_type = dry_type
    @terms = parse value
  end

  def each
    @terms.each { |v| yield v }
  end

  def positives
    @positives ||= @terms.reject(&:is_negative).map(&:value)
  end

  def negatives
    @negatives ||= @terms.select(&:is_negative).map(&:value)
  end

private

  def parse value
    splitted_value = value.is_a?(String) ? value.split(',') : [value.to_s]

    splitted_value.map do |term|
      is_negative = term[0] == '!'
      value = is_negative ? term[1..] : term

      OpenStruct.new(
        value: @dry_type ? @dry_type[value] : value,
        is_negative: is_negative
      )
    end
  end
end
