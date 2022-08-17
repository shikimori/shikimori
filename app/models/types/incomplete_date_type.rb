class Types::IncompleteDateType < ActiveModel::Type::Value
  def cast_value value
    value.is_a?(String) ? IncompleteDate.new(JSON.parse(value)) : value
  end

  # def serialize value
  #   # value.is_a?(ActiveSupport::Duration) ? value.iso8601 : value
  # end

  # def type
  #   :string
  # end

  # def cast(value)
  #   Currency.string_to_currency(value)
  # end

  # def deserialize(value)
  #   Currency.string_to_currency(value)
  # end

  def serialize value
    value.to_json
  end
end
