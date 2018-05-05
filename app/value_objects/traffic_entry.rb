class TrafficEntry < Dry::Struct
  attribute :date, Types::Strict::Date
  attribute :visitors, Types::Coercible::Integer
  attribute :visits, Types::Coercible::Integer
  attribute :page_views, Types::Coercible::Integer
end
