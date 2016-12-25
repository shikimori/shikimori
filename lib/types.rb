module Types
  include Dry::Types.module

  User = Dry::Types::Definition.new(::User)
  SpentTime = Dry::Types::Definition.new(::SpentTime)
end
