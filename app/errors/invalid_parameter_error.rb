class InvalidParameterError < ArgumentError
  attr_reader :field, :value

  def initialize field, value, additional = nil
    @field = field
    @value = value
    @additional = additional
  end

  def to_s
    "Invalid #{@field} value \"#{@value}\"#{ ". #{@additional}" if @additional}"
  end
end
