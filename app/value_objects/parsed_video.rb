class ParsedVideo < Dry::Struct
  attribute :author, Types::Strict::String.optional
  attribute :episode, Types::Coercible::Integer
  attribute :kind, Types::Strict::Symbol
  attribute :url, Types::Strict::String.optional
  attribute :source, Types::Strict::String
  attribute :language, Types::Strict::Symbol
end
