class TrafficEntry < Dry::Struct
  attribute :date, Types::Strict::Date
  attribute :visitors, Types::Coercible::Int
  attribute :visits, Types::Coercible::Int
  attribute :page_views, Types::Coercible::Int
end
