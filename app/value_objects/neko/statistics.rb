class Neko::Statistics
  include ShallowAttributes

  attribute :interval_0, Float, default: 0
  attribute :interval_1, Float, default: 0
  attribute :interval_2, Float, default: 0
  attribute :interval_3, Float, default: 0
  attribute :interval_4, Float, default: 0
  attribute :interval_5, Float, default: 0
  attribute :interval_6, Float, default: 0

  INTERVALS = [50, 100, 250, 400, 600, 1_000, 10_000]
end
