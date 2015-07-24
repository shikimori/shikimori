class AddIsDeletedToUserNicknameChanges < ActiveRecord::Migration
  def change
    add_column :user_nickname_changes, :is_deleted, :boolean, default: false
  end
end
