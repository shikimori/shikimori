class FillCachedRatesCountsInAnimesAndMangas < ActiveRecord::Migration[5.1]
  def up
    DbEntries::UpdateCachedRatesCounts.new.perform
  end
end
