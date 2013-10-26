class CreateAnimeCalendars < ActiveRecord::Migration
  def self.up
    create_table :anime_calendars do |t|
      t.integer :anime_id
      t.integer :episode
      t.datetime :start_at

      t.timestamps
    end
    add_index :anime_calendars, [:anime_id, :episode], :unique => true
  end

  def self.down
    drop_table :anime_calendars
  end
end
