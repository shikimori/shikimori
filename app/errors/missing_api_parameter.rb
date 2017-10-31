class MissingApiParameter < ArgumentError
  def initialize field_name
    @field_name = field_name
  end

  def to_s
    "Missing parameter #{@field_name}"
  end
end
