class Coub::Author < Dry::Struct
  attribute :permalink, Types::String
  attribute :name, Types::String
  attribute :avatar_template, Types::String
end
