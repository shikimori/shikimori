module Types
  include Dry::Types.module

  ShikiUser = Dry::Types::Definition.new(::User)
  ShikiSpentTime = Dry::Types::Definition.new(::SpentTime)
end
