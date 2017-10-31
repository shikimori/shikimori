class AddRolesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :roles, :string,
      null: false,
      default: [],
      array: true,
      limit: 4096
    add_index :users, :roles, using: :gin
  end
end
