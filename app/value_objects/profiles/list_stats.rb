class Profiles::ListStats < Dry::Struct
  constructor_type(:schema)

  attribute :id, Types::Coercible::Int
  attribute :name, Types::Strict::String
  attribute :size, Types::Coercible::Int
  attribute :grouped_id, Types::Coercible::String
  attribute :type, Types::Strict::String

  def localized_name
    UserRate.status_name(name, type).capitalize
  end

  def any?
    size > 0
  end
end
