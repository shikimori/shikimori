class Types::Scalars::PositiveInt < GraphQL::Types::Int
  description 'A positive integer (>= 1)'

  def self.coerce_input(input_value, ctx)
    int_value = super
    raise GraphQL::CoercionError, "#{input_value} is not a positive integer" if int_value < 1

    int_value
  end
end
