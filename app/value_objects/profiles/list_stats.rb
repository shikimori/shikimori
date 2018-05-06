class Profiles::ListStats < Dry::Struct
  attribute :id, Types::Coercible::Integer
  attribute :name, Types::Strict::String
  attribute :size, Types::Coercible::Integer
  attribute :grouped_id, Types::Coercible::String
  attribute :type, Types::Strict::String

  def localized_name
    UserRate.status_name(name, type).capitalize
  end

  def any?
    size.positive?
  end
end
