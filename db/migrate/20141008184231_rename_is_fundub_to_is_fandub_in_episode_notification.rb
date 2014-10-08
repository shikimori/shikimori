class RenameIsFundubToIsFandubInEpisodeNotification < ActiveRecord::Migration
  def change
    rename_column :episode_notifications, :is_fundub, :is_fandub
  end
end
