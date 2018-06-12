class Neko::Statistics < Dry::Struct
  attribute :interval_50, Types::Params::Decimal
  attribute :interval_100, Types::Params::Decimal
  attribute :interval_250, Types::Params::Decimal
  attribute :interval_400, Types::Params::Decimal
  attribute :interval_600, Types::Params::Decimal
  attribute :interval_1000, Types::Params::Decimal
end
