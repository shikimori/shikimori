class Coub::Results < Dry::Struct
  attribute :coubs, Types::Array.of(Coub::Entry)
  attribute :iterator, Types::String
end
