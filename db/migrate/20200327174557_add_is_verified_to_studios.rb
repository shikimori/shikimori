class AddIsVerifiedToStudios < ActiveRecord::Migration[5.2]
  def change
    add_column :studios, :is_verified, :boolean, default: false, null: false
  end
end
