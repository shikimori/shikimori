class Animes::RefreshStats::FilterScores
  method_object %i[score! amount! options!]

  OPTION_PREFIX = 'score_filter_'
  FILTER_REGEXP = /score_filter_\d+_(\d+)/

  def call
    [@amount - filter_amount, 0].max
  end

private

  def filter_amount
    @options
      .find { |option| option.starts_with? score_option_prefix }
      &.match(FILTER_REGEXP)
      &.send(:[], 1)
      &.to_i || 0
  end

  def score_option_prefix
    "#{OPTION_PREFIX}#{score}"
  end
end
