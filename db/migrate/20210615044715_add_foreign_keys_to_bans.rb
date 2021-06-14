class AddForeignKeysToBans < ActiveRecord::Migration[5.2]
  def change
    change_column :bans, :user_id, :integer,
      null: false
    add_foreign_key :bans, :users, column: :user_id
    add_foreign_key :bans, :users, column: :moderator_id

    change_column :bans, :duration, :integer,
      null: false
  end
end
