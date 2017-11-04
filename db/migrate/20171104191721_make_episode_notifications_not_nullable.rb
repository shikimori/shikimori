class MakeEpisodeNotificationsNotNullable < ActiveRecord::Migration[5.1]
  def change
    change_column :episode_notifications, :anime_id, :integer,
      null: false
    change_column :episode_notifications, :episode, :integer,
      null: false
    change_column :episode_notifications, :is_raw, :boolean,
      default: false,
      null: false
    change_column :episode_notifications, :is_subtitles, :boolean,
      default: false,
      null: false
    change_column :episode_notifications, :is_fandub, :boolean,
      default: false,
      null: false
    change_column :episode_notifications, :is_unknown, :boolean,
      default: false,
      null: false
  end
end
