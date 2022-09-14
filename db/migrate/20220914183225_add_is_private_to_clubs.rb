class AddIsPrivateToClubs < ActiveRecord::Migration[6.1]
  def change
    add_column :clubs, :is_private, :boolean, null: false, default: false
  end
end
