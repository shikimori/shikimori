class Neko::Stats
  include ShallowAttributes

  attribute :interval_0, Integer, default: 0
  attribute :interval_1, Integer, default: 0
  attribute :interval_2, Integer, default: 0
  attribute :interval_3, Integer, default: 0
  attribute :interval_4, Integer, default: 0
  attribute :interval_5, Integer, default: 0
  attribute :interval_6, Integer, default: 0

  INTERVALS = [50, 100, 250, 400, 600, 1_000, 999_999_999]

  def interval index
    send "interval_#{index}"
  end

  def increment! user_rates_count
    INTERVALS.each_with_index do |value, index|
      next unless user_rates_count <= value

      send "interval_#{index}=", send("interval_#{index}") + 1
      break
    end
  end
end
