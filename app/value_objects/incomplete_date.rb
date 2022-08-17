class IncompleteDate
  include ShallowAttributes
  include Types::JsonbActiveModel
  # include ActiveModel::Validations

  attribute :year, Integer, allow_nil: true
  attribute :month, Integer, allow_nil: true
  attribute :day, Integer, allow_nil: true
end
