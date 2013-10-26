class RenameAnimeRateToEntryRate < ActiveRecord::Migration
  def self.up
    rename_column :anime_rates, :anime_id, :target_id
    add_column :anime_rates, :target_type, :string
    rename_table :anime_rates, :user_rates

    ActiveRecord::Base.connection.execute("update user_rates set target_type='Anime'")
  end

  def self.down
    rename_table :user_rates, :anime_rates
    remove_column :anime_rates, :target_type
    rename_column :anime_rates, :target_id, :anime_id
  end
end
