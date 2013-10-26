class CreateAnimeRates < ActiveRecord::Migration
  def self.up
    create_table :anime_rates do |t|
      t.integer :user_id
      t.integer :anime_id
      t.integer :score
      t.integer :status
      t.integer :episodes

      t.timestamps
    end
  end

  def self.down
    drop_table :anime_rates
  end
end
