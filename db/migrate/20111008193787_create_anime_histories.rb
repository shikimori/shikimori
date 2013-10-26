class CreateAnimeHistories < ActiveRecord::Migration
  def self.up
    create_table :anime_histories do |t|
      t.integer :user_id
      t.integer :anime_id
      t.string :action
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :anime_histories
  end
end
