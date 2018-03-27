class FillCachedRatesCountsInAnimesAndMangas < ActiveRecord::Migration[5.1]
  def up
    Animes::UpdateCachedRatesCounts.new.perform
  end
end
