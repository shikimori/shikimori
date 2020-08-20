class RenameScheduleToBroadcastInAnimes < ActiveRecord::Migration[5.2]
  def change
    rename_column :animes, :schedule, :broadcast
  end
end
