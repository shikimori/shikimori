class RemoveNullableFromFieldsInUsers < ActiveRecord::Migration
  def up
    change_column :users, :email, :string, null: true
    change_column :users, :encrypted_password, :string, null: true, limit: 128
  end

  def down
    change_column :users, :encrypted_password, :string, null: false, limit: 128
    change_column :users, :email, :string, null: false
  end
end
