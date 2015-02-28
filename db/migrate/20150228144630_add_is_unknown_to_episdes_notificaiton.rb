class AddIsUnknownToEpisdesNotificaiton < ActiveRecord::Migration
  def change
    add_column :episode_notifications, :is_unknown, :boolean
  end
end
