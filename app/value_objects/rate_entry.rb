class RateEntry < SimpleDelegator
  attr_reader :rate

  def initialize target, rate
    super target
    @rate = rate
  end
end
