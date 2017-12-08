class InvalidParameterError < ArgumentError
  attr_reader :field, :value

  def initialize field, value
    @field = field
    @value = value
  end

  def to_s
    "Invalid #{@field} value #{@value}"
  end
end
