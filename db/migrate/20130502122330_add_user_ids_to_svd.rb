class AddUserIdsToSvd < ActiveRecord::Migration
  def change
    add_column :svds, :user_ids, :binary, :limit => 1.megabyte
  end
end
