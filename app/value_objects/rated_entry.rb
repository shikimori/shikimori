class RatedEntry < SimpleDelegator
  attr_reader :rate

  def initialize target, rate
    super(target.decorated? ? target : target.decorate)
    @rate = rate
  end

  def current_user
    rate
  end
end
