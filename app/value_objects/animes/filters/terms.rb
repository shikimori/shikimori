class Animes::Filters::Terms
  include Enumerable

  def initialize value
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
    value
      .split(',')
      .map do |term|
        is_negative = term[0] == '!'

        OpenStruct.new(
          value: is_negative ? term[1..-1] : term,
          is_negative: is_negative
        )
      end
  end
end
