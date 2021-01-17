class ChangeUserNicknameChangesTable < ActiveRecord::Migration[5.2]
  def change
    change_column :user_nickname_changes, :user_id, :integer,
      null: false,
      index: true,
      foreign_key: true
    change_column :user_nickname_changes, :value, :string,
      null: false
    change_column :user_nickname_changes, :is_deleted, :boolean,
      default: false,
      null: false
  end
end
