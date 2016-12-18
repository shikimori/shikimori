class RenameScheduleToBroadcastInAnimes < ActiveRecord::Migration
  def change
    rename_column :animes, :schedule, :broadcast
  end
end
