class TrafficEntry
  include ShallowAttributes

  attribute :date, Date
  attribute :visitors, Integer
  attribute :visits, Integer
  attribute :page_views, Integer
end
