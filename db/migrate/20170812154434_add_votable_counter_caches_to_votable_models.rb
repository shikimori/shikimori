class AddVotableCounterCachesToVotableModels < ActiveRecord::Migration[5.1]
  def change
    %i[critiques cosplay_galleries collections].each do |table_name|
      add_column table_name, :cached_votes_up, :integer, default: 0
      add_column table_name, :cached_votes_down, :integer, default: 0
    end
  end
end
