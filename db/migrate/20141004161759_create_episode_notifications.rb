class CreateEpisodeNotifications < ActiveRecord::Migration
  def change
    create_table :episode_notifications do |t|
      t.references :anime, index: true
      t.integer :episode
      t.boolean :is_raw
      t.boolean :is_subtitles
      t.boolean :is_fundub

      t.timestamps
    end
  end
end
